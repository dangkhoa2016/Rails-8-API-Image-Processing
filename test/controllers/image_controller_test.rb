require "test_helper"

class ImageControllerTest < ActionDispatch::IntegrationTest
  Minitest.after_run { puts "ImageControllerTest completed" }

  test "get index without 'url' parameter" do
    get image_index_url
    assert_response :bad_request
  end

  test "get index with invalid 'url' parameter" do
    get image_index_url, params: { url: "invalid" }
    assert_response :bad_request
  end

  test "get index with valid 'url' parameter" do
    get image_index_url, params: { url: "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png" }
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
    image = Vips::Image.new_from_buffer(response.body, "")
    assert_equal 714, image.get("width")
    assert_equal 500, image.get("height")
  end
end
