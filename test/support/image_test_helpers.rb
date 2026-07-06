module ImageTestHelpers
  def stub_request(url, filename, format, height, width)
    ext = format == "jpeg" ? "jpg" : format
    image = Vips::Image.black(height, width)
    buffer = image.write_to_buffer(".#{ext}")

    WebMock.stub_request(:get, url).to_return(
      status: 200,
      headers: { "Content-Type" => "image/#{format}" },
      body: buffer
    )
  end
end
