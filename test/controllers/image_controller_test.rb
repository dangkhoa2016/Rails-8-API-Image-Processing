require "test_helper"

class ImageControllerTest < ActionDispatch::IntegrationTest
  Minitest.after_run { puts "ImageControllerTest completed" }

  setup do
    @original_faraday_connection = Faraday.default_connection
    @user = users(:admin)

    @token, @payload = Warden::JWTAuth::UserEncoder.new.call(@user, :user, nil)
    @headers = { "Authorization": "Bearer #{@token}" }
  end

  teardown do
    Faraday.default_connection = @original_faraday_connection
  end

  def stub_request(url, file, image_format, expect_width, expect_height)
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      body = File.open("test/fixtures/files/#{file}", "rb").read
      original_image = Magick::Image.from_blob(body).first
      assert_equal expect_width, original_image.columns
      assert_equal expect_height, original_image.rows
      stub.get(url) { |env| [ 200, { "Content-Type": "image/#{image_format}" }, body ] }
    end
    Faraday.new { |b| b.adapter(:test, stubs) }
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

  test "get index with valid 'token' and without 'url' parameter" do
    get image_index_url, headers: @headers
    assert_response :bad_request
  end

  test "get index with valid 'token' and with invalid 'url' parameter" do
    get image_index_url, params: { url: "invalid" }, headers: @headers
    assert_response :bad_request
  end

  test "get index with valid 'token' and with valid 'url' parameter" do
    get image_index_url, params: { url: "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png" }, headers: @headers
    assert_response :success
  end

  test "get index with valid 'token' and with valid 'url' parameter and with 'resize' parameter" do
    url = "https://test.local/images/sample.jpeg"
    Faraday.default_connection = stub_request(url, "sample.jpeg", "jpeg", 400, 713)

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
    Faraday.default_connection = stub_request(url, "sample.png", "png", 500, 714)

    get image_index_url, params: { url: url, rotate: "90", format: "jpg" }, headers: @headers
    assert_response :success
    response_headers = response.headers
    content_type = response_headers["Content-Type"]
    assert_equal "image/jpg", content_type
    file_name = response_headers["Content-Disposition"]
    assert_equal "inline; filename=\"sample.jpg\"", file_name
    image = Magick::Image.from_blob(body).first
    assert_equal 714, image.columns
    assert_equal 500, image.rows
  end
end
