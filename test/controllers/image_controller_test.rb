require "test_helper"
require "minitest/mock"

class ImageControllerTest < ActionDispatch::IntegrationTest
  Minitest.after_run { puts "ImageControllerTest completed" }

  setup do
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

  def http_response(content_type:, body:)
    Struct.new(:headers, :body).new({ "content-type" => content_type }, body)
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
    assert_ssrf_blocked("https://blocked.local/images/sample.jpeg", addresses: ["127.0.0.1"])
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
end
