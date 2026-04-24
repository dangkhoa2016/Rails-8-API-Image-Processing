require "test_helper"
require "minitest/mock"

class ImageTransformHelperTest < ActiveSupport::TestCase
  test "convert_color handles array transparent parsed and fallback values" do
    assert_equal [ 1, 2, 3 ], helper_call(:convert_color, [ 1, 2, 3 ])
    assert_equal [], helper_call(:convert_color, "transparent")

    parsed_color = Struct.new(:rgb).new({ red: 12, green: 34, blue: 56 })
    ColorConversion::Color.stub(:new, parsed_color) do
      assert_equal [ 12, 34, 56 ], helper_call(:convert_color, "navy")
    end

    ColorConversion::Color.stub(:new, ->(_color) { raise StandardError, "invalid" }) do
      assert_equal [ 255, 255, 255 ], helper_call(:convert_color, "invalid")
    end
  end

  test "modify_resize handles array variants" do
    current_size = [ 400, 800 ]

    assert_equal 0, helper_call(:modify_resize, nil, current_size)
    assert_equal [ 0.5, { kernel: "linear" } ], helper_call(:modify_resize, [ "0.5", { kernel: "linear" } ], current_size)
    assert_equal [ 0.5, {} ], helper_call(:modify_resize, [ "200", "400" ], current_size)
    assert_equal [], helper_call(:modify_resize, [ "0", "0" ], current_size)
    assert_equal 2, helper_call(:modify_resize, 2, current_size)
  end

  test "modify_resize handles hash variants and calculate_scale branches" do
    current_size = [ 400, 800 ]

    assert_equal [ 0.25, { crop: "centre" } ], helper_call(:modify_resize, { width: 100, crop: "centre" }, current_size)
    assert_equal [ 0.5, {} ], helper_call(:modify_resize, { height: 400 }, current_size)
    assert_equal [ 1.5, { crop: "entropy" } ], helper_call(:modify_resize, { scale: 1.5, crop: "entropy" }, current_size)
    assert_equal [], helper_call(:modify_resize, { width: 0, height: 0 }, current_size)

    assert_equal 0.5, helper_call(:calculate_scale, 200, 400, current_size)
    assert_equal 0.25, helper_call(:calculate_scale, 100, 0, current_size)
    assert_equal 0.5, helper_call(:calculate_scale, 0, 400, current_size)
  end

  test "modify_rotation handles array hash scalar and nil" do
    assert_equal 0, helper_call(:modify_rotation, nil)
    assert_equal [ "90", {} ], helper_call(:modify_rotation, [ "90", { background: "transparent" } ])

    parsed_color = Struct.new(:rgb).new({ red: 9, green: 8, blue: 7 })
    ColorConversion::Color.stub(:new, parsed_color) do
      assert_equal [ "45", { background: [ 9, 8, 7 ] } ], helper_call(:modify_rotation, { angle: "45", bg: "navy" })
    end

    assert_equal [ 180, { background: [ 255, 255, 255 ] } ], helper_call(:modify_rotation, 180)
  end

  test "determine_result_format covers string array and hash inputs" do
    assert_equal "png", helper_call(:determine_result_format, "jpg", "PNG")
    assert_equal "webp", helper_call(:determine_result_format, "jpg", [ "WEBP" ])
    assert_equal "gif", helper_call(:determine_result_format, "jpg", [ { format: "GIF" } ])
    assert_equal "bmp", helper_call(:determine_result_format, "jpg", { format: "BMP" })
  end

  test "apply_image_format handles array and hash inputs" do
    transform_methods = {}
    helper_call(:apply_image_format, transform_methods, [ "PNG" ], "png")
    assert_equal({ format: "png" }, transform_methods[:image_format])

    transform_methods = {}
    helper_call(:apply_image_format, transform_methods, [ { format: "WEBP", quality: 80 } ], "webp")
    assert_equal({ format: "webp" }, transform_methods[:image_format])
    assert_equal 80, transform_methods[:quality]

    transform_methods = {}
    helper_call(:apply_image_format, transform_methods, [ "jpg", 70 ], "jpg")
    assert_equal({ format: "jpg" }, transform_methods[:image_format])
    assert_equal 70, transform_methods[:quality]

    transform_methods = {}
    helper_call(:apply_image_format, transform_methods, { format: "JPEG", quality: 60 }, "jpeg")
    assert_equal({ format: "jpeg" }, transform_methods[:image_format])
    assert_equal 60, transform_methods[:quality]
  end

  test "get_transform_params adds flatten quality rotate and resize" do
    transform_methods = {
      background: "transparent",
      format: { format: "JPG", quality: 85 },
      rotate: { angle: "90", background: "transparent" },
      resize: { scale: 0.5 }
    }

    result = ImageTransformHelper.get_transform_params(transform_methods, "png", [ 400, 800 ])

    assert_equal({ format: "jpg" }, result[:image_format])
    assert_equal 85, result[:quality]
    assert_equal({ background: [] }, result[:flatten])
    assert_equal [ "90", {} ], result[:rotate]
    assert_equal [ 0.5, {} ], result[:resize]
  end

  test "apply_flatten_if_required adds flatten for jpeg when not already set" do
    transform_methods = {}
    helper_call(:apply_flatten_if_required, transform_methods, "jpg", [ 255, 255, 255 ])
    assert_equal({ background: [ 255, 255, 255 ] }, transform_methods[:flatten])

    transform_methods = {}
    helper_call(:apply_flatten_if_required, transform_methods, "jpeg", [ 0, 0, 0 ])
    assert_equal({ background: [ 0, 0, 0 ] }, transform_methods[:flatten])
  end

  test "apply_flatten_if_required skips flatten when already set" do
    existing = { background: [ 255, 0, 0 ] }
    transform_methods = { flatten: existing }
    helper_call(:apply_flatten_if_required, transform_methods, "jpg", [ 255, 255, 255 ])
    assert_equal existing, transform_methods[:flatten], "should not overwrite existing flatten"
  end

  test "apply_flatten_if_required does not set flatten for png or webp format" do
    transform_methods = {}
    helper_call(:apply_flatten_if_required, transform_methods, "png", [ 255, 255, 255 ])
    assert_nil transform_methods[:flatten]

    transform_methods = {}
    helper_call(:apply_flatten_if_required, transform_methods, "webp", [ 255, 255, 255 ])
    assert_nil transform_methods[:flatten]
  end

  private

  def helper_call(method_name, *args)
    ImageTransformHelper.send(method_name, *args)
  end
end
