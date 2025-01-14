# example:

# {
#   resize_to_fit: [300, 300],
#   sharpen: [10, 2],
# }
# /image?url=https://.....png&resize_to_fit[]=300&resize_to_fit[]=300&sharpen[]=10&sharpen[]=2

class ImageController < ApplicationController
  before_action :authorize_request

  # GET /index
  def index
    # Get image URL from query string
    url = request.params.delete(:url)
    if url.blank?
      url = request.params.delete(:u)
    end

    # Check if the URL is present
    if url.blank?
      render json: { error: I18n.translate("errors.url_parameter_is_required") }, status: :bad_request
      return
    end

    # Check if the URL is valid
    unless url =~ URI::DEFAULT_PARSER.make_regexp
      render json: { error: I18n.translate("errors.invalid_url") }, status: :bad_request
      return
    end

    # Download the image from the URL
    response_body = nil
    response_headers = nil
    begin
      response = Faraday.get(url)  # Download the image from the URL
      response_headers = response.headers
      response_body = response.body
    rescue => e
      render json: { error: I18n.translate("errors.failed_to_download_image", message: e.message) }, status: :unprocessable_entity
      return
    end

    begin
      image = Magick::Image.from_blob(response.body).first  # Create an image object from the buffer

      original_format = response_headers["content-type"].split("/").last || "jpg"
      transform_methods = ImageTransformHelper.get_transform_params(get_transform_methods, original_format)

      quality = transform_methods.delete(:quality) || transform_methods.delete(:q)
      quality = quality.to_i if quality.present?

      image_format = transform_methods.delete(:image_format)
      result_format = image_format.present? ? image_format[:format] : original_format

      has_rotate = transform_methods.keys.include?("rotate")
      if has_rotate
        image = apply_background_color(image, get_background_color(transform_methods), true)

        # Loop through query string parameters and apply corresponding operations
        image = apply_image_transformations(image, transform_methods)
      else
        # Loop through query string parameters and apply corresponding operations
        image = apply_image_transformations(image, transform_methods)

        image = apply_background_color(image, get_background_color(transform_methods), false)
      end

      # Save the image to memory
      image_buffer = image.to_blob do |image|
        image.quality = quality if quality.present? && quality > 0
        image.format = result_format
      end

      # Return the image as binary data (image/jpeg)
      send_data image_buffer, type: "image/#{result_format}", disposition: "inline; filename=\"#{get_file_name_without_extension(url)}.#{result_format}\""

    rescue => e
      Rails.logger.error "Failed to process image: #{e.message}"
      render json: { error: I18n.translate("errors.failed_to_process_image", message: e.message) }, status: :unprocessable_entity
    end
  end

  private

  def get_transform_methods
    params.permit!.to_h.except(:controller, :action, :url, :u, :image)
  end

  # def get_hash_from_query_string(query_string)
  #   Rack::Utils.parse_nested_query(query_string) rescue {}
  # end

  def get_file_name_without_extension(url)
    File.basename(url, ".*")
  end

  def convert_params_value_string_to_number(param)
    if param.is_a?(Hash)
      param.each do |key, value|
        param[key] = convert_params_value_string_to_number(value)
      end
      return param
    end

    if param.is_a?(Array)
      return param.map { |value| convert_params_value_string_to_number(value) }
    end

    if param.to_i.to_s == param
      param.to_i
    elsif param.to_f.to_s == param
      param.to_f
    else
      param
    end
  end

  def apply_background_color(image, background_color, has_rotate)
    puts "apply_background_color: #{background_color}"

    if background_color.present?
      background_color = ImageTransformHelper.convert_color(background_color) rescue nil
    end

    if background_color.present?
      image.background_color = background_color
      if has_rotate
        image.alpha(Magick::BackgroundAlphaChannel)
      else
        image.alpha(Magick::RemoveAlphaChannel)
      end
    end

    image
  end

  def get_background_color(transform_methods = {})
    background_color = transform_methods.delete(:background) if transform_methods[:background].present?

    # if background_color.blank?
    #   background_color = ImageTransformHelper.white_background
    # end

    background_color
  end

  # Apply image transformations based on query string parameters
  # example: /images?sharpen[]=10&sharpen[]=2&resize_to_fit[]=300&resize_to_fit[]=300
  # {"sharpen"=>[10,2], "resize_to_fit"=>[300,300]}
  # refer: https://rmagick.github.io/usage.html
  def apply_image_transformations(image, transform_methods = {})
    puts "apply_image_transformations: #{transform_methods}"
    # Loop through query string parameters and apply corresponding operations

    transform_methods.each do |method, params|
      next if params.blank?

      if image.respond_to?(method) && image.method(method).parameters.any?
        puts "applying #{method} with params #{params}"

        if method == "rotate" && params.size > 1
          options = params.pop || {}
          background_color = ImageTransformHelper.convert_color(options[:background]) if options[:background].present?
        end

        begin
          if params.is_a?(Array)
            params = convert_params_value_string_to_number(params)
            # find the first hash in the array
            hash_params = params.find { |p| p.is_a?(Hash) } || {}
            rest_params = params - [ hash_params ]
            image = image.send(method, *rest_params, **hash_params)
          elsif params.is_a?(Hash)
            image = image.send(method, **convert_params_value_string_to_number(params))
          else
            image = image.send(method, convert_params_value_string_to_number(params))
          end

          if method == "rotate" && background_color.present?
            background = Magick::Image.new(image.columns, image.rows) { |options| options.background_color = background_color }
            image = background.composite(image, 0, 0, Magick::OverCompositeOp)
          end
        rescue => e
          puts "Error applying #{method} with params #{params}: #{e.message}"
        end
      elsif image.respond_to?(method) && image.method("#{method}=").parameters.any?
        begin
          puts "applying #{method} with params #{params}"
          image.send("#{method}=", params)
        rescue => e
          puts "Error applying property #{method} with params #{params}: #{e.message}"
        end
      end
    end

    image
  end
end
