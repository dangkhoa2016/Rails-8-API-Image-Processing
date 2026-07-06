require "test_helper"

class ImageControllerTest < ActionDispatch::IntegrationTest
  Minitest.after_run { puts "ImageControllerTest completed" }

  setup do
    @user = users(:admin)

    @token, @payload = Warden::JWTAuth::UserEncoder.new.call(@user, :user, nil)
    @headers = { "Authorization": "Bearer #{@token}" }
  end

  def stub_request(url, file, image_format, expect_width, expect_height)
    body = File.binread("test/fixtures/files/#{file}")
    original_image = Vips::Image.new_from_buffer(body, "")
    assert_equal expect_width, original_image.get("width")
    assert_equal expect_height, original_image.get("height")

    WebMock.stub_request(:get, url).to_return(
      status: 200,
      headers: { "Content-Type" => "image/#{image_format}" },
      body: body
    )
  end

  test "get index without 'token'" do
    get image_index_url, params: { url: "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png" }
    assert_response :unauthorized
  end

  test "get index with invalid 'token'" do
    get image_index_url,
      params: { url: "http://example.com/image.jpg" },
      headers: { "Authorization": "Bearer invalid" }
    assert_response :unauthorized
  end

  test "get index with non-admin user returns unauthorized" do
    non_admin = users(:one)
    token, _payload = Warden::JWTAuth::UserEncoder.new.call(non_admin, :user, nil)

    get image_index_url,
      params: { url: "https://test.local/images/sample.jpeg" },
      headers: { "Authorization": "Bearer #{token}" }

    assert_response :unauthorized
    assert_equal({ "errors" => I18n.t("errors.must_be_administrator") }, json_response)
  end

  test "get index with valid 'token' and without 'url' parameter" do
    get image_index_url, headers: @headers
    assert_response :bad_request
  end

  test "get index with valid 'token' and with invalid 'url' parameter" do
    get image_index_url, params: { url: "invalid" }, headers: @headers
    assert_response :bad_request
  end

  test "get index with valid 'token' and with valid 'url' parameter" do
    url = "https://test.local/images/sample.jpeg"
    stub_request(url, "sample.jpeg", "jpeg", 400, 713)

    get image_index_url, params: { url: url }, headers: @headers
    assert_response :success
  end

  test "get index with valid 'token' and with valid 'url' parameter and with 'resize' parameter" do
    url = "https://test.local/images/sample.jpeg"
    stub_request(url, "sample.jpeg", "jpeg", 400, 713)

    get image_index_url, params: { url: url, resize: "0.5" }, headers: @headers
    assert_response :success
    response_headers = response.headers
    content_type = response_headers["Content-Type"]
    assert_equal "image/jpeg", content_type
    file_name = response_headers["Content-Disposition"]
    assert_equal "inline; filename=\"sample.jpeg\"", file_name
  end

  test "get index with valid 'token' and with valid 'url' parameter and with 'rotate' and 'format' parameter" do
    url = "https://test.local/images/sample.png"
    stub_request(url, "sample.png", "png", 500, 714)

    get image_index_url, params: { url: url, rotate: "90", format: "jpg" }, headers: @headers
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
    WebMock.stub_request(:get, url).to_raise(StandardError.new("download failed"))

    get image_index_url, params: { url: url }, headers: @headers

    assert_response :unprocessable_entity
    assert_equal(
      I18n.translate("errors.failed_to_download_image", message: "download failed"),
      json_response.fetch("error")
    )
  end

  test "get index with valid token applies quality when q parameter is present" do
    url = "https://test.local/images/sample.jpeg"
    stub_request(url, "sample.jpeg", "jpeg", 400, 713)

    get image_index_url, params: { url: url, q: "80" }, headers: @headers

    assert_response :success
  end

  test "get index with valid token returns unprocessable entity when image processing fails" do
    url = "https://test.local/images/broken.jpeg"
    WebMock.stub_request(:get, url).to_return(
      status: 200,
      headers: { "Content-Type" => "image/jpeg" },
      body: "raw-image"
    )

    get image_index_url, params: { url: url }, headers: @headers

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
