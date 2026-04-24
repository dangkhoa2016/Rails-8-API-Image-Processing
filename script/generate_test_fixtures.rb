#!/usr/bin/env ruby
# script/generate_test_fixtures.rb
#
# Generates fixture images for image processing tests.
# Run once from project root: bundle exec ruby script/generate_test_fixtures.rb
#
# Produces:
#   test/fixtures/files/quadrants.png  — 200x200, 4 solid-color quadrants
#   test/fixtures/files/alpha.png      — 100x100 RGBA with transparent top-right quadrant
#   test/fixtures/files/portrait_exif.jpg — 400x600 landscape saved with EXIF orientation=6
#     (so it visually appears as a portrait when auto-rotated)

require "vips"

OUTPUT_DIR = File.expand_path("../test/fixtures/files", __dir__)

# ---------------------------------------------------------------------------
# quadrants.png — 200x200, four solid-color quadrants
#   top-left:     RED   [255,   0,   0]
#   top-right:    GREEN [  0, 255,   0]
#   bottom-left:  BLUE  [  0,   0, 255]
#   bottom-right: YELLOW[255, 255,   0]
# ---------------------------------------------------------------------------
puts "Generating quadrants.png..."

red    = Vips::Image.black(100, 100, bands: 3) + [ 255, 0, 0 ]
green  = Vips::Image.black(100, 100, bands: 3) + [ 0, 255, 0 ]
blue   = Vips::Image.black(100, 100, bands: 3) + [ 0, 0, 255 ]
yellow = Vips::Image.black(100, 100, bands: 3) + [ 255, 255, 0 ]

top    = red.join(green, :horizontal)
bottom = blue.join(yellow, :horizontal)
quadrants = top.join(bottom, :vertical)

quadrants.write_to_file(File.join(OUTPUT_DIR, "quadrants.png"))
puts "  -> #{quadrants.width}x#{quadrants.height}, bands=#{quadrants.bands}"

# ---------------------------------------------------------------------------
# alpha.png — 100x100 RGBA: top-left quadrant red, top-right transparent,
#             bottom-left blue, bottom-right yellow
# ---------------------------------------------------------------------------
puts "Generating alpha.png..."

def add_alpha(img)
  alpha = Vips::Image.black(img.width, img.height, bands: 1).invert
  img.bandjoin(alpha)
end

def transparent_block(w, h)
  Vips::Image.black(w, h, bands: 4)
end

red_a    = add_alpha(Vips::Image.black(50, 50, bands: 3) + [ 255, 0, 0 ])
trans    = transparent_block(50, 50)
blue_a   = add_alpha(Vips::Image.black(50, 50, bands: 3) + [ 0, 0, 255 ])
yellow_a = add_alpha(Vips::Image.black(50, 50, bands: 3) + [ 255, 255, 0 ])

top_a    = red_a.join(trans, :horizontal)
bottom_a = blue_a.join(yellow_a, :horizontal)
alpha_img = top_a.join(bottom_a, :vertical)

alpha_img.write_to_file(File.join(OUTPUT_DIR, "alpha.png"))
puts "  -> #{alpha_img.width}x#{alpha_img.height}, bands=#{alpha_img.bands}"

# ---------------------------------------------------------------------------
# portrait_exif.jpg — 400x600 landscape image stored with EXIF orientation=6
#   (orientation 6 = 90° clockwise rotation needed; after autorot → 600x400)
# ---------------------------------------------------------------------------
puts "Generating portrait_exif.jpg..."

# Build a simple gradient landscape image (400 wide x 600 tall stored data)
portrait_data = Vips::Image.black(400, 600, bands: 3) + [ 120, 80, 200 ]

# Write to a temp buffer first, then reload and set the EXIF orientation
tmp_path = File.join(OUTPUT_DIR, "_tmp_portrait.jpg")
portrait_data.write_to_file(tmp_path)

exif_img = Vips::Image.new_from_file(tmp_path)
exif_img = exif_img.copy
exif_img.set("orientation", 6)
exif_img.write_to_file(File.join(OUTPUT_DIR, "portrait_exif.jpg"))

File.delete(tmp_path)
puts "  -> #{exif_img.width}x#{exif_img.height}, orientation=#{exif_img.get('orientation') rescue 'n/a'}"

puts "\nAll fixtures generated in #{OUTPUT_DIR}"
