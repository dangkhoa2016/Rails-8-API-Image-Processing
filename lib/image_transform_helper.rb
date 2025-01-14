class ImageTransformHelper
  class << self
    def get_transform_params(transform_methods, original_format)
      bg = determine_background_color(transform_methods)
      transform_methods[:background] = bg

      result_format = determine_image_format(transform_methods)

      image_format = determine_result_format(original_format, result_format)

      apply_image_format(transform_methods, image_format, result_format)

      puts "get_transform_params: #{transform_methods}"

      if transform_methods.key?(:rotate)
        transform_methods[:rotate] = modify_rotation(transform_methods[:rotate])
      end

      if transform_methods.key?(:resize)
        transform_methods[:resize] = modify_resize(transform_methods[:resize])
      end

      transform_methods
    end

    def white_background
      "#FFFFFF"
    end

    def convert_color(color)
      return color if color.blank?
      if color.is_a?(Array)
        if color.all? { |c| c.is_a?(Integer) }
          color = { r: color[0], g: color[1], b: color[2] }
        else
          return color
        end
      end

      if color&.downcase == "transparent"
        return []
      end

      parsed_color = ColorConversion::Color.new(color) rescue nil

      if parsed_color.present?
        parsed_color.hex
      else
        white_background
      end
    end

    private

    def modify_resize(resize)
      return 0 unless resize

      if resize.is_a?(Array)
        width, height = resize
        if height.present?
          params = [ width.to_i, height.to_i ].compact
          params.size == 2 ? params : []
        else
          scale = width.to_f
          scale > 0 && scale < 10 ? [ scale ] : []
        end
      elsif resize.is_a?(Hash)
        scale = resize[:scale]
        scale = scale.to_f if scale.present?
        if scale.present? && scale > 0 && scale < 10
          [ scale ]
        else
          width = resize[:width]&.to_i
          height = resize[:height]&.to_i
          width.present? && height.present? && width > 0 && height > 0 ? [ width, height ] : []
        end
      else
        resize
      end
    end

    def calculate_scale(width, height, current_size)
      scale_width = 0, scale_height = 0

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
        bg = (options && (options[:bg] || options[:background]))
        bg = convert_color(bg)
        [ angle, bg.present? ? { background: convert_color(bg) } : {} ]
      elsif rotation.is_a?(Hash)
        angle = rotation[:angle]
        bg = rotation[:bg] || rotation[:background]
        bg = convert_color(bg)
        [ angle, bg.present? ? { background: convert_color(bg) } : {} ]
      else
        [ rotation ]
      end
    end

    def determine_background_color(transform_methods)
      bg = transform_methods.delete(:bg) || transform_methods.delete(:background)
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
          result_format = first.downcase
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
  end
end
