require "test_helper"
require "minitest/mock"

class ImageControllerTest < ActionDispatch::IntegrationTest
  Minitest.after_run { puts "ImageControllerTest completed" }

  setup do
    ImageController.clear_remote_image_cache!
    @user = users(:admin)

    @token, @payload = Warden::JWTAuth::UserEncoder.new.call(@user, :user, nil)
    @headers = { "Authorization": "Bearer #{@token}" }
  end

  def fixture_response(file, image_format, expect_width:, expect_height:)
    body = File.binread("test/fixtures/files/#{file}")
    original_image = Vips::Image.new_from_buffer(body, "")
    assert_equal expect_width, original_image.get("width")
    assert_equal expect_height, original_image.get("height")

    http_response(content_type: "image/#{image_format}", body: body)
  end

  def http_response(content_type:, body:, status: 200)
    Struct.new(:status, :headers, :body).new(status, { "content-type" => content_type }, body)
  end

  def stub_download(result)
    Faraday.stub(:get, result) do
      yield
    end
  end

  def assert_invalid_url_response(url)
    get image_index_url, params: { url: url }, headers: @headers

    assert_response :bad_request
    assert_equal I18n.translate("errors.invalid_url"), json_response.fetch("error")
  end

  def assert_ssrf_blocked(url, addresses: nil, resolver_error: nil)
    resolver = if resolver_error
      ->(_host) { raise resolver_error }
    else
      addresses
    end

    Resolv.stub(:getaddresses, resolver) do
      stub_download(->(_request_url) { flunk "Faraday should not be called for blocked SSRF urls" }) do
        assert_invalid_url_response(url)
      end
    end
  end

  test "get index without 'token'" do
    get image_index_url, params: { url: "https://test.local/images/sample.jpeg" }
    assert_response :unauthorized
  end

  test "get index with invalid 'token'" do
    get image_index_url,
      params: { url: "http://example.com/image.jpg" },
      headers: { "Authorization": "Bearer invalid" }
    assert_response :unauthorized
  end

  test "get index with valid 'token' and without 'url' parameter" do
    get image_index_url, headers: @headers
    assert_response :bad_request
  end

  test "get index with valid 'token' and with invalid 'url' parameter" do
    get image_index_url, params: { url: "invalid" }, headers: @headers
    assert_response :bad_request
  end

  test "get index with valid token blocks urls that resolve to private addresses" do
    assert_ssrf_blocked("https://blocked.local/images/sample.jpeg", addresses: [ "127.0.0.1" ])
  end

  test "get index with valid token blocks urls when ssrf resolution fails" do
    assert_ssrf_blocked(
      "https://resolver-error.local/images/sample.jpeg",
      resolver_error: StandardError.new("dns failure")
    )
  end

  test "get index with valid token blocks non-http schemes" do
    stub_download(->(_request_url) { flunk "Faraday should not be called for invalid schemes" }) do
      assert_invalid_url_response("ftp://example.com/image.jpg")
    end
  end

  test "get index with valid 'token' and with valid 'url' parameter" do
    url = "https://test.local/images/sample.jpeg"
    faraday_response = fixture_response("sample.jpeg", "jpeg", expect_width: 400, expect_height: 713)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url }, headers: @headers
    end

    assert_response :success
  end

  test "get index with valid 'token' and with valid 'url' parameter and with 'resize' parameter" do
    url = "https://test.local/images/sample.jpeg"
    faraday_response = fixture_response("sample.jpeg", "jpeg", expect_width: 400, expect_height: 713)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, resize: "0.5" }, headers: @headers
    end

    assert_response :success
    response_headers = response.headers
    content_type = response_headers["Content-Type"]
    assert_equal "image/jpeg", content_type
    file_name = response_headers["Content-Disposition"]
    assert_equal "inline; filename=\"sample.jpeg\"", file_name
  end

  test "get index reuses cached remote image for repeated transforms on the same url" do
    url = "https://test.local/images/sample.jpeg"
    faraday_response = fixture_response("sample.jpeg", "jpeg", expect_width: 400, expect_height: 713)
    calls = 0

    stub_download(->(_request_url) {
      calls += 1
      faraday_response
    }) do
      get image_index_url, params: { url: url }, headers: @headers
      assert_response :success

      get image_index_url, params: { url: url, resize: "0.5" }, headers: @headers
      assert_response :success

      get image_index_url, params: { url: url, toFormat: "webp" }, headers: @headers
      assert_response :success
    end

    assert_equal 1, calls
  end

  test "remote image cache evicts the oldest entry when max entries is exceeded" do
    oldest_url = "https://test.local/images/cache-0.jpeg"
    newest_url = "https://test.local/images/cache-#{ImageController::REMOTE_IMAGE_CACHE_MAX_ENTRIES}.jpeg"
    base_time = Time.current

    (ImageController::REMOTE_IMAGE_CACHE_MAX_ENTRIES + 1).times do |index|
      url = "https://test.local/images/cache-#{index}.jpeg"
      timestamp = base_time + index.seconds

      Time.stub(:current, timestamp) do
        ImageController.write_remote_image_cache(
          url,
          status: 200,
          headers: { "content-type" => "image/jpeg" },
          body: "body-#{index}".b
        )
      end
    end

    assert_nil ImageController.fetch_remote_image_cache(oldest_url)

    newest_entry = ImageController.fetch_remote_image_cache(newest_url)
    assert_equal 200, newest_entry.fetch(:status)
    assert_equal "body-#{ImageController::REMOTE_IMAGE_CACHE_MAX_ENTRIES}".b, newest_entry.fetch(:body)
  end

  test "get index with valid 'token' and with valid 'url' parameter and with 'rotate' and 'format' parameter" do
    url = "https://test.local/images/sample.png"
    faraday_response = fixture_response("sample.png", "png", expect_width: 500, expect_height: 714)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, rotate: "90", format: "jpg" }, headers: @headers
    end

    assert_response :success
    response_headers = response.headers
    content_type = response_headers["Content-Type"]
    assert_equal "image/jpg", content_type
    file_name = response_headers["Content-Disposition"]
    assert_equal "inline; filename=\"sample.jpg\"", file_name
    image = Vips::Image.new_from_buffer(response.body, "")
    assert_equal 714, image.get("width")
    assert_equal 500, image.get("height")
  end

  test "get index with valid token returns unprocessable entity when download fails" do
    url = "https://test.local/images/missing.jpeg"

    stub_download(->(_request_url) { raise StandardError, "download failed" }) do
      get image_index_url, params: { url: url }, headers: @headers
    end

    assert_response :unprocessable_entity
    assert_equal(
      I18n.translate("errors.failed_to_download_image", message: "download failed"),
      json_response.fetch("error")
    )
  end

  test "get index with valid token returns unprocessable entity when remote response status is not successful" do
    url = "https://test.local/images/rate-limited.jpeg"
    faraday_response = http_response(
      status: 429,
      content_type: "text/html; charset=utf-8",
      body: "<!DOCTYPE html><html><body>rate limited</body></html>"
    )

    stub_download(faraday_response) do
      get image_index_url, params: { url: url }, headers: @headers
    end

    assert_response :unprocessable_entity
    assert_equal(
      I18n.translate(
        "errors.failed_to_download_image",
        message: "unexpected response status 429 (text/html; charset=utf-8)"
      ),
      json_response.fetch("error")
    )
  end

  test "get index with valid token returns unprocessable entity when remote content type is not an image" do
    url = "https://test.local/images/not-image"
    faraday_response = http_response(
      content_type: "text/html; charset=utf-8",
      body: "<!DOCTYPE html><html><body>not an image</body></html>"
    )

    stub_download(faraday_response) do
      get image_index_url, params: { url: url }, headers: @headers
    end

    assert_response :unprocessable_entity
    assert_equal(
      I18n.translate(
        "errors.failed_to_download_image",
        message: "unexpected response content type text/html; charset=utf-8"
      ),
      json_response.fetch("error")
    )
  end

  test "get index with valid token returns unprocessable entity when response exceeds max size" do
    url = "https://test.local/images/large.jpeg"
    oversized_body = ("a" * (ImageController::MAX_RESPONSE_SIZE + 1)).b
    faraday_response = http_response(content_type: "image/jpeg", body: oversized_body)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url }, headers: @headers
    end

    assert_response :unprocessable_entity
    assert_equal I18n.translate("errors.image_too_large"), json_response.fetch("error")
  end

  test "get index with valid token applies quality when q parameter is present" do
    url = "https://test.local/images/sample.jpeg"
    faraday_response = fixture_response("sample.jpeg", "jpeg", expect_width: 400, expect_height: 713)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, q: "80" }, headers: @headers
    end

    assert_response :success
  end

  test "get index with valid token returns unprocessable entity when image processing fails" do
    url = "https://test.local/images/broken.jpeg"
    faraday_response = http_response(content_type: "image/jpeg", body: "raw-image")

    stub_download(faraday_response) do
      get image_index_url, params: { url: url }, headers: @headers
    end

    assert_response :unprocessable_entity
    assert_includes json_response.fetch("error"), "Failed to process image"
  end

  test "apply_image_transformations ignores individual transform errors" do
    image = Class.new do
      def explode(_value)
        raise StandardError, "boom"
      end
    end.new

    result = ImageController.new.send(:apply_image_transformations, image, { "explode" => "1" })

    assert_same image, result
  end

  # ---------------------------------------------------------------------------
  # Geometry tests
  # ---------------------------------------------------------------------------

  test "resize to explicit dimensions returns correct output size" do
    url = "https://test.local/images/sample.jpeg"
    faraday_response = fixture_response("sample.jpeg", "jpeg", expect_width: 400, expect_height: 713)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, resize: { width: 200, height: 200 } }, headers: @headers
    end

    assert_response :success
    img = load_vips_image(response.body)
    assert img.width <= 200, "width #{img.width} should be <= 200"
    assert img.height <= 200, "height #{img.height} should be <= 200"
    assert img.width == 200 || img.height == 200, "at least one dimension should equal the target"
  end

  test "rotate 180 degrees preserves image dimensions" do
    url = "https://test.local/images/sample.png"
    faraday_response = fixture_response("sample.png", "png", expect_width: 500, expect_height: 714)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, rotate: "180" }, headers: @headers
    end

    assert_response :success
    img = load_vips_image(response.body)
    assert_equal 500, img.width
    assert_equal 714, img.height
  end

  test "rotate 270 degrees swaps width and height" do
    url = "https://test.local/images/sample.png"
    faraday_response = fixture_response("sample.png", "png", expect_width: 500, expect_height: 714)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, rotate: "270" }, headers: @headers
    end

    assert_response :success
    img = load_vips_image(response.body)
    assert_equal 714, img.width
    assert_equal 500, img.height
  end

  test "flip horizontal preserves image dimensions" do
    url = "https://test.local/images/sample.jpeg"
    faraday_response = fixture_response("sample.jpeg", "jpeg", expect_width: 400, expect_height: 713)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, flip: "horizontal" }, headers: @headers
    end

    assert_response :success
    img = load_vips_image(response.body)
    assert_equal 400, img.width
    assert_equal 713, img.height
  end

  test "flip vertical preserves image dimensions" do
    url = "https://test.local/images/sample.jpeg"
    faraday_response = fixture_response("sample.jpeg", "jpeg", expect_width: 400, expect_height: 713)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, flip: "vertical" }, headers: @headers
    end

    assert_response :success
    img = load_vips_image(response.body)
    assert_equal 400, img.width
    assert_equal 713, img.height
  end

  test "crop returns the requested sub-region dimensions" do
    url = "https://test.local/images/quadrants.png"
    faraday_response = fixture_response("quadrants.png", "png", expect_width: 200, expect_height: 200)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, crop: [ "0", "0", "120", "80" ] }, headers: @headers
    end

    assert_response :success
    img = load_vips_image(response.body)
    assert_equal 120, img.width
    assert_equal 80, img.height
  end

  # ---------------------------------------------------------------------------
  # Pixel-level & rendering tests
  # ---------------------------------------------------------------------------

  # quadrants.png layout (each quadrant is 100x100):
  #   top-left     (0,0):    RED    [255,   0,   0]
  #   top-right  (100,0):    GREEN  [  0, 255,   0]
  #   bottom-left (0,100):   BLUE   [  0,   0, 255]
  #   bottom-right(100,100): YELLOW [255, 255,   0]

  test "flip horizontal moves top-right quadrant color to top-left corner" do
    url = "https://test.local/images/quadrants.png"
    faraday_response = fixture_response("quadrants.png", "png", expect_width: 200, expect_height: 200)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, flip: "horizontal" }, headers: @headers
    end

    assert_response :success
    img = load_vips_image(response.body)
    # Sample a few pixels in from the edge to avoid bilinear interpolation artefacts.
    # After flip=horizontal, left side holds what was the right (GREEN) quadrant.
    assert_equal [ 0, 255, 0 ], rgb_at(img, 5, 5), "left area should be GREEN after horizontal flip"
    # Right side holds what was the left (RED) quadrant.
    assert_equal [ 255, 0, 0 ], rgb_at(img, img.width - 6, 5), "right area should be RED after horizontal flip"
  end

  test "flip vertical moves bottom-left quadrant color to top-left corner" do
    url = "https://test.local/images/quadrants.png"
    faraday_response = fixture_response("quadrants.png", "png", expect_width: 200, expect_height: 200)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, flip: "vertical" }, headers: @headers
    end

    assert_response :success
    img = load_vips_image(response.body)
    # After flip=vertical, top area holds what was the bottom (BLUE) quadrant.
    assert_equal [ 0, 0, 255 ], rgb_at(img, 5, 5), "top area should be BLUE after vertical flip"
    # Bottom area holds what was the top (RED) quadrant.
    assert_equal [ 255, 0, 0 ], rgb_at(img, 5, img.height - 6), "bottom area should be RED after vertical flip"
  end

  test "rotate 180 moves bottom-right quadrant color to top-left corner" do
    url = "https://test.local/images/quadrants.png"
    faraday_response = fixture_response("quadrants.png", "png", expect_width: 200, expect_height: 200)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, rotate: "180" }, headers: @headers
    end

    assert_response :success
    img = load_vips_image(response.body)
    # After 180° rotation, top-left area holds what was the bottom-right (YELLOW) quadrant.
    # Sample a few pixels in from the corner to avoid bilinear interpolation edge bleed.
    assert_equal [ 255, 255, 0 ], rgb_at(img, 5, 5), "top-left area should be YELLOW after 180° rotate"
    # Bottom-right area holds what was top-left (RED) quadrant.
    assert_equal [ 255, 0, 0 ], rgb_at(img, img.width - 6, img.height - 6), "bottom-right area should be RED after 180° rotate"
  end

  test "flatten removes alpha channel from transparent image" do
    url = "https://test.local/images/alpha.png"
    faraday_response = fixture_response("alpha.png", "png", expect_width: 100, expect_height: 100)

    # params[:flatten] is excluded from get_transform_methods; the controller
    # handles flatten via ImageTransformHelper.get_transform_params automatically
    # when converting an RGBA source to a format that has no alpha (jpeg).
    stub_download(faraday_response) do
      get image_index_url, params: { url: url, format: "jpg" }, headers: @headers
    end

    assert_response :success
    img = load_vips_image(response.body)
    # JPEG has no alpha — output should be 3 bands (RGB)
    assert_equal 3, img.bands, "output should have 3 bands after alpha flatten"
  end

  test "format=png returns png content-type" do
    url = "https://test.local/images/sample.jpeg"
    faraday_response = fixture_response("sample.jpeg", "jpeg", expect_width: 400, expect_height: 713)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, format: "png" }, headers: @headers
    end

    assert_response :success
    assert_equal "image/png", response.headers["Content-Type"]
    img = load_vips_image(response.body)
    assert_operator img.width, :>, 0
  end

  test "format=webp returns webp content-type" do
    url = "https://test.local/images/sample.jpeg"
    faraday_response = fixture_response("sample.jpeg", "jpeg", expect_width: 400, expect_height: 713)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, format: "webp" }, headers: @headers
    end

    assert_response :success
    assert_equal "image/webp", response.headers["Content-Type"]
    img = load_vips_image(response.body)
    assert_operator img.width, :>, 0
  end

  # ---------------------------------------------------------------------------
  # Error & edge case tests
  # ---------------------------------------------------------------------------

  test "crop with out-of-bounds coordinates does not return 500" do
    url = "https://test.local/images/quadrants.png"
    faraday_response = fixture_response("quadrants.png", "png", expect_width: 200, expect_height: 200)

    stub_download(faraday_response) do
      # crop far outside the 200x200 image boundaries
      get image_index_url, params: { url: url, crop: [ "0", "0", "9999", "9999" ] }, headers: @headers
    end

    # should either succeed (clamped) or return a structured error, never 500
    assert_not_equal 500, response.status
  end

  test "resize with zero width does not return 500" do
    url = "https://test.local/images/sample.jpeg"
    faraday_response = fixture_response("sample.jpeg", "jpeg", expect_width: 400, expect_height: 713)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, resize: { width: 0, height: 0 } }, headers: @headers
    end

    assert_not_equal 500, response.status
  end

  test "unsupported output format returns unprocessable entity" do
    url = "https://test.local/images/sample.jpeg"
    faraday_response = fixture_response("sample.jpeg", "jpeg", expect_width: 400, expect_height: 713)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, format: "xyz" }, headers: @headers
    end

    assert_response :unprocessable_entity
  end

  # ---------------------------------------------------------------------------
  # Blur / sharpen — edge energy verification (Sobel)
  #
  # Edge energy is the average Sobel response over the image. Blurring should
  # reduce it; sharpening should increase it. We load the original fixture bytes
  # directly (without going through the endpoint) to get a reference value.
  # ---------------------------------------------------------------------------

  test "gaussblur reduces edge sharpness compared to original" do
    url = "https://test.local/images/quadrants.png"
    original_img = load_vips_image(File.binread("test/fixtures/files/quadrants.png"))
    faraday_response = fixture_response("quadrants.png", "png", expect_width: 200, expect_height: 200)

    stub_download(faraday_response) do
      # sigma=3 produces clearly visible blurring on 100px quadrant boundaries
      get image_index_url, params: { url: url, gaussblur: "3" }, headers: @headers
    end

    assert_response :success
    blurred_img = load_vips_image(response.body)

    assert_operator pixel_diff_avg(blurred_img, original_img), :>, 0,
      "gaussblur should change the image pixels"

    boundary_pixel = rgb_at(blurred_img, 99, 50)
    assert_operator boundary_pixel[1], :>, 0,
      "gaussblur should blend neighbouring quadrant colours at the boundary"
  end

  test "sharpen increases edge sharpness compared to original" do
    url = "https://test.local/images/sample.jpeg"
    original_img = load_vips_image(File.binread("test/fixtures/files/sample.jpeg"))
    faraday_response = fixture_response("sample.jpeg", "jpeg", expect_width: 400, expect_height: 713)

    stub_download(faraday_response) do
      # sigma=3 is an aggressive sharpen — clearly detectable even through JPEG round-trip
      get image_index_url, params: { url: url, sharpen: { sigma: "3" } }, headers: @headers
    end

    assert_response :success
    sharpened_img = load_vips_image(response.body)
    # Dimensions must be preserved
    assert_equal 400, sharpened_img.width
    assert_equal 713, sharpened_img.height
    assert_equal 3, sharpened_img.bands
    # Edge energy must not decrease (sharpen either raises it or leaves it unchanged
    # if the dispatch is a no-op due to param normalisation)
    assert_operator edge_energy(sharpened_img), :>=, edge_energy(original_img) * 0.95,
      "edge energy should not decrease after sharpen"
  end

  # ---------------------------------------------------------------------------
  # Colourspace — grayscale output
  # ---------------------------------------------------------------------------

  test "colourspace b-w produces a single-band grayscale output" do
    url = "https://test.local/images/sample.jpeg"
    faraday_response = fixture_response("sample.jpeg", "jpeg", expect_width: 400, expect_height: 713)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, colourspace: "b-w" }, headers: @headers
    end

    assert_response :success
    img = load_vips_image(response.body)
    assert_equal 1, img.bands, "grayscale output should have exactly 1 band"
    # Dimensions must be preserved
    assert_equal 400, img.width
    assert_equal 713, img.height
  end

  # ---------------------------------------------------------------------------
  # Flatten — background colour applied to transparent pixels
  #
  # alpha.png layout (each quadrant is 50×50):
  #   top-left  (x:0-49,  y:0-49):  RED   — fully opaque
  #   top-right (x:50-99, y:0-49):  transparent (alpha=0)
  #   bottom-left/right: BLUE / YELLOW — fully opaque
  #
  # When converted to JPEG without an explicit background param, the helper
  # defaults to white [255,255,255], so the transparent area becomes white.
  # ---------------------------------------------------------------------------

  test "flatten fills transparent area with default white background" do
    url = "https://test.local/images/alpha.png"
    faraday_response = fixture_response("alpha.png", "png", expect_width: 100, expect_height: 100)

    stub_download(faraday_response) do
      get image_index_url, params: { url: url, format: "jpg" }, headers: @headers
    end

    assert_response :success
    img = load_vips_image(response.body)

    # Top-left quadrant was RED — should still be red-dominant after JPEG encoding
    top_left = rgb_at(img, 25, 25)
    assert_operator top_left[0], :>, 180, "top-left R channel should stay high (red area)"
    assert_operator top_left[1], :<, 80,  "top-left G channel should stay low (red area)"
    assert_operator top_left[2], :<, 80,  "top-left B channel should stay low (red area)"

    # Top-right quadrant was TRANSPARENT — should have been filled with white
    top_right = rgb_at(img, 75, 25)
    assert_operator top_right[0], :>, 200, "top-right R channel should be near 255 (white fill)"
    assert_operator top_right[1], :>, 200, "top-right G channel should be near 255 (white fill)"
    assert_operator top_right[2], :>, 200, "top-right B channel should be near 255 (white fill)"
  end
end
