
require 'rmagick'

def method_1
  img_path = './input.png'

  image = Magick::Image.read(img_path).first
  image.rotate!(120)

  new_background_color = 'red'
  width = image.columns
  height = image.rows
  background = Magick::Image.new(width, height) { |opts| opts.background_color = new_background_color }

  background.composite!(image, 0, 0, Magick::OverCompositeOp)
  # background = background.resize_to_fit(100, 100)

  background.write('./output.png')
end

def method_2
  img_path = './input.png'

  image = Magick::Image.read(img_path).first
  image.rotate!(120)

  image = image.opaque('white', 'red')

  image.write('./output.png')
end

def method_3
  img_path = './input.png'

  image = Magick::Image.read(img_path).first
  image.rotate!(120)

  image = image.transparent('white', alpha: Magick::TransparentAlpha)
  # image = image.transparent('white', alpha: 0)

  image.write('./output.png')
end

def method_4
  img_path = './input.png'

  image = Magick::Image.read(img_path).first
  image.rotate!(120)

  image.background_color = 'red'

  image.write('./output.png')
end

def method_5
  img_path = './input.png'

  image = Magick::Image.read(img_path).first
  image.rotate!(120)

  image = image.transparent(Magick::Pixel.from_color('red'))

  image.write('./output.png')
end

def method_6
  img_path = './input.png'

  image = Magick::Image.read(img_path).first
  image.rotate!(120)
  # image = image.opaque('white', 'red')
  image = image.opaque('white', 'lime')

  # new_background_color = 'lime'
  new_background_color = 'red'
  background = Magick::Image.new(image.columns, image.rows) do |opts|
    opts.background_color = new_background_color
  end

  background.composite!(image, 0, 0, Magick::OverCompositeOp)
  # background = background.resize_to_fit(100, 100)

  background.write('./output.png')
end

def method_7
  img_path = './input.png'

  image = Magick::Image.read(img_path).first
  image.rotate!(120)
  # image.border_color = 'red'

  new_background_color = 'red'
  background = Magick::Image.new(image.columns, image.rows) do |opts|
    opts.background_color = new_background_color
  end

  background.composite!(image, 0, 0, Magick::OverCompositeOp)
  # background = background.resize_to_fit(100, 100)

  background = background.transparent('white', alpha: Magick::TransparentAlpha)

  background.write('./output.png')
end

# method_1
# method_2
# method_3
# method_4
# method_5
# method_6
# method_7
