module ImageTestHelpers
  # Load raw bytes into a Vips::Image for assertion
  def load_vips_image(bytes)
    Vips::Image.new_from_buffer(bytes, "")
  end

  # Return the [R, G, B] pixel at (x, y) normalised to 0-255 regardless of bit depth.
  # Casts to uchar so that 16-bit uint16 images (e.g. PNG saved by libvips) give the same
  # values as 8-bit images (65535 green → 255, etc.).
  def rgb_at(img, x, y)
    img.cast(:uchar).getpoint(x, y).first(3).map(&:round)
  end

  # Average per-pixel difference between two Vips images (float; lower = more similar).
  # Images must be the same dimensions. Useful for comparing lossy-encoded output.
  def pixel_diff_avg(actual, expected)
    diff = (actual.cast("float") - expected.cast("float")).abs
    diff.avg
  end

  # Edge sharpness score using the Sobel operator (higher = sharper edges).
  # Normalises to uchar first so it works for both 8-bit and 16-bit sources.
  def edge_energy(img)
    img.cast(:uchar).colourspace(:b_w).sobel.avg
  end
end
