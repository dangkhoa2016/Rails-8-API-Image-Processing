module ImageTestHelpers
  # Load raw bytes into a Vips::Image for assertion
  def load_vips_image(bytes)
    Vips::Image.new_from_buffer(bytes, "")
  end

  # Return the [R, G, B] pixel at (x, y) normalised to 0-255 regardless of bit depth.
  def rgb_at(img, x, y)
    img.cast(:uchar).getpoint(x, y).first(3).map(&:round)
  end

  # Average per-pixel difference between two Vips images (float; lower = more similar).
  def pixel_diff_avg(actual, expected)
    diff = (actual.cast("float") - expected.cast("float")).abs
    diff.avg
  end
end
