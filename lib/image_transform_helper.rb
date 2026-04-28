class ImageTransformHelper
  class InvalidResizeLimitsError < StandardError; end

  class << self
    DEFAULT_MAX_RESIZE_WIDTH = 4096
    DEFAULT_MAX_RESIZE_HEIGHT = 4096
    DEFAULT_MAX_RESIZE_SCALE = 8.0

    def get_transform_params(transform_methods, original_format, current_size)
      bg = determine_background_color(transform_methods)
      image_format = determine_image_format(transform_methods)

      result_format = determine_result_format(original_format, image_format)

      apply_image_format(transform_methods, image_format, result_format)

      apply_flatten_if_required(transform_methods, result_format, bg) if result_format.present?

      if transform_methods.key?(:rotate)
        transform_methods[:rotate] = modify_rotation(transform_methods[:rotate])
      end

      if transform_methods.key?(:resize)
        transform_methods[:resize] = modify_resize(transform_methods[:resize], current_size)
      end

      transform_methods
    end

    def max_resize_width
      positive_integer_env("IMAGE_MAX_RESIZE_WIDTH", DEFAULT_MAX_RESIZE_WIDTH)
    end

    def max_resize_height
      positive_integer_env("IMAGE_MAX_RESIZE_HEIGHT", DEFAULT_MAX_RESIZE_HEIGHT)
    end

    def max_resize_scale
      positive_float_env("IMAGE_MAX_RESIZE_SCALE", DEFAULT_MAX_RESIZE_SCALE)
    end

    private

    def white_background
      [ 255, 255, 255 ]
    end

    def convert_color(color)
      return color if color.is_a?(Array)

      if color&.downcase == "transparent"
        return []
      end

      parsed_color = ColorConversion::Color.new(color) rescue nil

      if parsed_color.present?
        parsed_color.rgb.values
      else
        white_background
      end
    end

    def modify_resize(resize, current_size)
      return 0 unless resize

      if resize.is_a?(Array)
        scale, options = resize
        if scale.to_f > 0.0 && (options.is_a?(Hash) || scale.to_f <= 10)
          validate_resize_limits!(scale: scale)
          [ scale.to_f, options || {} ]
        else # width and height
          validate_resize_limits!(width: scale, height: options)
          scale = calculate_scale(scale.to_i, options.to_i, current_size)
          if scale
            validate_resize_limits!(scale: scale)
            [ scale, {} ]
          else
            []
          end
        end
      elsif resize.is_a?(Hash)
        width = resize[:width]
        height = resize[:height]
        scale = resize[:scale]
        options = resize.except(:width, :height, :scale)
        validate_resize_limits!(width: width, height: height)

        if !scale
          scale = calculate_scale(width, height, current_size)
        elsif scale.to_f > 0.0
          validate_resize_limits!(scale: scale)
          scale = scale.to_f
        end

        if scale
          validate_resize_limits!(scale: scale) if scale.to_f > 0.0
          [ scale, options || {} ]
        else
          []
        end
      else
        validate_resize_limits!(scale: resize) if resize.to_f > 0.0
        resize
      end
    end

    def validate_resize_limits!(width: nil, height: nil, scale: nil)
      too_wide = width.to_f > max_resize_width
      too_tall = height.to_f > max_resize_height
      too_large_scale = scale.to_f > max_resize_scale

      return unless too_wide || too_tall || too_large_scale

      raise InvalidResizeLimitsError,
        I18n.translate(
          "errors.invalid_resize_limits",
          max_width: max_resize_width,
          max_height: max_resize_height,
          max_scale: display_number(max_resize_scale)
        )
    end

    def positive_integer_env(key, default)
      value = ENV[key].to_i
      value.positive? ? value : default
    end

    def positive_float_env(key, default)
      value = ENV[key].to_f
      value.positive? ? value : default
    end

    def display_number(value)
      value.to_i == value ? value.to_i : value
    end

    def calculate_scale(width, height, current_size)
      scale_width = 0
      scale_height = 0

      if width.to_f > 0
        scale_width = width.to_f / current_size[0]
      end

      if height.to_f > 0
        scale_height = height.to_f / current_size[1]
      end

      if scale_width > 0 && scale_height > 0
        [ scale_width, scale_height ].min
      elsif scale_width > 0
        scale_width
      elsif scale_height > 0
        scale_height
      end
    end

    def modify_rotation(rotation)
      return 0 unless rotation

      if rotation.is_a?(Array)
        angle, options = rotation
        bg = (options && (options[:bg] || options[:background])) || white_background # white background instead of black
        bg = convert_color(bg)
        [ angle, bg.present? ? { background: convert_color(bg) } : {} ]
      elsif rotation.is_a?(Hash)
        angle = rotation[:angle]
        bg = rotation[:bg] || rotation[:background] || white_background
        bg = convert_color(bg)
        [ angle, bg.present? ? { background: convert_color(bg) } : {} ]
      else
        [ rotation, { background: convert_color(white_background) } ]
      end
    end

    def determine_background_color(transform_methods)
      bg = transform_methods.delete(:bg) || transform_methods.delete(:background) || white_background
      convert_color(bg)
    end

    def determine_image_format(transform_methods)
      transform_methods.delete(:format) ||
        transform_methods.delete(:f) ||
        transform_methods.delete(:toFormat)
    end

    def determine_result_format(original_format, image_format)
      result_format = original_format

      if image_format.present?
        if image_format.is_a?(String)
          result_format = image_format.downcase
        elsif image_format.is_a?(Array)
          first = image_format.first
          if first.is_a?(String)
            result_format = first.downcase
          elsif first.is_a?(Hash)
            result_format = first[:format].downcase if first[:format].present?
          end
        elsif image_format.is_a?(Hash)
          result_format = image_format[:format].downcase if image_format[:format].present?
        end
      end
      result_format
    end

    def apply_image_format(transform_methods, image_format, result_format)
      return unless image_format.present?

      transform_methods[:image_format] = { format: result_format }

      case image_format
      when String
        transform_methods[:image_format][:format] = result_format || image_format
      when Array
        handle_array_image_format(transform_methods, image_format)
      when Hash
        handle_hash_image_format(transform_methods, image_format)
      end
    end

    def handle_array_image_format(transform_methods, image_format)
      if image_format.size == 1
        first = image_format.first
        if first.is_a?(String)
          transform_methods[:image_format][:format] = first.downcase
        elsif first.is_a?(Hash)
          apply_hash_image_format_fields(transform_methods, first)
        end
      end

      if image_format.size == 2 && image_format[1].present?
        transform_methods[:quality] = image_format[1]
      end
    end

    def handle_hash_image_format(transform_methods, image_format)
      apply_hash_image_format_fields(transform_methods, image_format)
    end

    def apply_hash_image_format_fields(transform_methods, image_format)
      result_format = image_format[:format]&.downcase
      transform_methods[:image_format][:format] = result_format if result_format

      if image_format[:quality].present?
        transform_methods[:quality] = image_format.delete(:quality)
      end
    end

    def apply_flatten_if_required(transform_methods, result_format, bg)
      if transform_methods[:flatten].blank? && [ "jpeg", "jpg" ].include?(result_format)
        transform_methods[:flatten] = { background: bg }
      end
    end
  end
end
