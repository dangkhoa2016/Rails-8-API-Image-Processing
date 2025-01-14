
require 'rmagick'

url = 'https://.../4213719.png'
response = Faraday.get(url)
image = Magick::Image.from_blob(response.body).first

image.resize(100, 100)
image.spread(5)

query_string = "sharpen%5Bx1%5D=1&shrink%5B%5D=1&shrink%5B%5D=2&shrink%5B%5D%5Bxshrink%5D=1"
parsed_hash = Rack::Utils.parse_query(query_string)

# ----------------------------

image = Magick::Image.read('./input.png').first

image = image.rotate(120)
image = image.opaque_channel('#fff', 'red')

image.write('./output.png')

# ----------------------------
