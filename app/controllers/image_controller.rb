# example:

# {
#   shrink: [5, 5, { xshrink: 50 }],
#   sharpen: { x1: 0.8, sigma: 0.5 }
# }
# /image?url=https://.....png&shrink[]=5&shrink[]=5&shrink[][xshrink]=50&sharpen[x1]=0.8&sharpen[sigma]=0.5

require "resolv"

class ImageController < ApplicationController
  before_action :authorize_request

  MAX_RESPONSE_SIZE = 20.megabytes

  BLOCKED_IP_RANGES = [
    IPAddr.new("127.0.0.0/8"),   # loopback
    IPAddr.new("10.0.0.0/8"),    # private class A
    IPAddr.new("172.16.0.0/12"), # private class B
    IPAddr.new("192.168.0.0/16"), # private class C
    IPAddr.new("169.254.0.0/16"), # link-local / AWS metadata
    IPAddr.new("::1"),           # IPv6 loopback
    IPAddr.new("fc00::/7")       # IPv6 unique local
  ].freeze

  # GET /index
  def index
    url = request.params.delete(:url)
    url = request.params.delete(:u) if url.blank?

    if url.blank?
      render json: { error: I18n.translate("errors.url_parameter_is_required") }, status: :bad_request
      return
    end

    unless url =~ URI::DEFAULT_PARSER.make_regexp
      render json: { error: I18n.translate("errors.invalid_url") }, status: :bad_request
      return
    end

    if ssrf_blocked?(url)
      render json: { error: I18n.translate("errors.invalid_url") }, status: :bad_request
      return
    end

    response_body = nil
    response_headers = nil
    begin
      response = Faraday.get(url)
      response_headers = response.headers
      response_body = response.body

      if response_body.bytesize > MAX_RESPONSE_SIZE
        render json: { error: I18n.translate("errors.image_too_large") }, status: :unprocessable_entity
        return
      end
    rescue => e
      render json: { error: I18n.translate("errors.failed_to_download_image", message: e.message) }, status: :unprocessable_entity
      return
    end

    begin
      image = Vips::Image.new_from_buffer(response_body, "")  # Create an image object from the buffer

      original_format = response_headers["content-type"].split("/").last || "jpg"
      transform_methods = ImageTransformHelper.get_transform_params(get_transform_methods, original_format, image.size)

      quality = transform_methods.delete(:quality) || transform_methods.delete(:q)
      quality = quality.to_i if quality.present?

      image_format = transform_methods.delete(:image_format)
      result_format = image_format.present? ? image_format[:format] : original_format

      # Loop through query string parameters and apply corresponding operations
      image = apply_image_transformations(image, transform_methods)

      if [ "jpeg", "jpg" ].include?(result_format) && image.format != :uchar
        image = image.cast(:uchar)
      end

      # Save the image to memory
      save_params = ".#{result_format}"
      if quality.present? && quality > 0
        save_params += "[Q=#{quality}]"  # Set the quality of the image
      end
      image_buffer = image.write_to_buffer(save_params)

      # Return the image as binary data (image/jpeg)
      send_data image_buffer, type: "image/#{result_format}", disposition: "inline; filename=\"#{get_file_name_without_extension(url)}.#{result_format}\""

    rescue => e
      Rails.logger.error "Failed to process image: #{e.message}"
      render json: { error: I18n.translate("errors.failed_to_process_image", message: e.message) }, status: :unprocessable_entity
    end
  end

  private

  def ssrf_blocked?(url)
    uri = URI.parse(url)
    return true unless uri.scheme.in?(%w[http https])

    addresses = Resolv.getaddresses(uri.host)
    return false if addresses.empty? # DNS won't resolve → Faraday will fail naturally

    addresses.any? do |addr|
      BLOCKED_IP_RANGES.any? { |range| range.include?(IPAddr.new(addr)) }
    end
  rescue
    true
  end

  def get_transform_methods
    # params.permit! is intentional here: image transform parameters are dynamic Vips method
    # names supplied by the caller (e.g. sharpen[x1]=1, resize[width]=300). There is no fixed
    # set of keys to enumerate, so an allowlist is not practical. The hash is processed further
    # by ImageTransformHelper before being passed to Vips, limiting the actual attack surface.
    # The Brakeman mass-assignment warning for this line is suppressed in config/brakeman.ignore.
    params.permit!.to_h.except(:controller, :action, :url, :u, :image, :flatten)
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

  # Apply image transformations based on query string parameters
  # example: /images?sharpen[x1]=1&shrink[]=1&shrink[]=2&shrink[][xshrink]=1
  # {"sharpen"=>{"x1"=>"1"}, "shrink"=>["1", "2", {"xshrink"=>"1"}]}
  # refer: https://libvips.github.io/ruby-vips/Vips/Image.html
  def apply_image_transformations(image, transform_methods = {})
    # Loop through query string parameters and apply corresponding operations

    transform_methods.each do |method, params|
      next if params.blank?

      if image.respond_to?(method) && image.method(method).parameters.any?

        if method == "rotate" && image.bands == 4 && params.last.present?
          params.last[:background].push(255)
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
        rescue => e
          Rails.logger.warn "Error applying #{method} with params #{params}: #{e.message}"
        end
      end
    end

    image
  end
end
