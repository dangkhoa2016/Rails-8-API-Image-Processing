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
  REMOTE_IMAGE_CACHE_TTL = 5.minutes
  REMOTE_IMAGE_CACHE_MAX_ENTRIES = 64

  class RemoteImageTooLargeError < StandardError; end

  BLOCKED_IP_RANGES = [
    IPAddr.new("127.0.0.0/8"),   # loopback
    IPAddr.new("10.0.0.0/8"),    # private class A
    IPAddr.new("172.16.0.0/12"), # private class B
    IPAddr.new("192.168.0.0/16"), # private class C
    IPAddr.new("169.254.0.0/16"), # link-local / AWS metadata
    IPAddr.new("::1"),           # IPv6 loopback
    IPAddr.new("fe80::/10"),     # IPv6 link-local
    IPAddr.new("fc00::/7")       # IPv6 unique local
  ].freeze

  class << self
    def clear_remote_image_cache!
      remote_image_cache_mutex.synchronize do
        remote_image_cache.clear
      end
    end

    def fetch_remote_image_cache(url)
      remote_image_cache_mutex.synchronize do
        prune_remote_image_cache!
        entry = remote_image_cache[url]
        return if entry.blank?

        {
          status: entry[:status],
          headers: entry[:headers].dup,
          body: entry[:body]
        }
      end
    end

    def write_remote_image_cache(url, status:, headers:, body:)
      remote_image_cache_mutex.synchronize do
        prune_remote_image_cache!
        remote_image_cache[url] = {
          status: status,
          headers: headers.dup,
          body: body,
          cached_at: Time.current
        }

        trim_remote_image_cache!
      end
    end

    private

    def remote_image_cache
      @remote_image_cache ||= {}
    end

    def remote_image_cache_mutex
      @remote_image_cache_mutex ||= Mutex.new
    end

    def prune_remote_image_cache!
      expires_before = Time.current - REMOTE_IMAGE_CACHE_TTL
      remote_image_cache.delete_if { |_url, entry| entry[:cached_at] <= expires_before }
    end

    def trim_remote_image_cache!
      while remote_image_cache.size > REMOTE_IMAGE_CACHE_MAX_ENTRIES
        oldest_url, = remote_image_cache.min_by { |_url, entry| entry[:cached_at] }
        remote_image_cache.delete(oldest_url)
      end
    end
  end

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
      response = fetch_remote_image(url)
      response_headers = response.fetch(:headers)
      response_status = response.fetch(:status).to_i
      response_content_type = response_headers["content-type"].to_s

      unless response_status.between?(200, 299)
        raise StandardError, "unexpected response status #{response_status} (#{response_content_type.presence || "unknown content type"})"
      end

      unless response_content_type.start_with?("image/")
        raise StandardError, "unexpected response content type #{response_content_type.presence || "unknown"}"
      end

      response_body = response.fetch(:body)
    rescue RemoteImageTooLargeError
      render json: { error: I18n.translate("errors.image_too_large") }, status: :unprocessable_entity
      return
    rescue => e
      render json: { error: I18n.translate("errors.failed_to_download_image", message: e.message) }, status: :unprocessable_entity
      return
    end

    begin
      image = Vips::Image.new_from_buffer(response_body, "")  # Create an image object from the buffer

      original_format = response_headers["content-type"].to_s.split(";").first.split("/").last || "jpg"
      transform_methods = ImageTransformHelper.get_transform_params(get_transform_methods, original_format, image.size)
      transform_methods.delete(:flatten) if transform_methods[:flatten].present? && image.bands <= 3

      quality = transform_methods.delete(:quality) || transform_methods.delete(:q)
      quality = quality.to_i if quality.present?

      if quality.present? && !(1..100).cover?(quality)
        render json: { error: I18n.translate("errors.invalid_image_quality") }, status: :unprocessable_entity
        return
      end

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

      self.response.set_header("X-Image-Width", image.width.to_s)
      self.response.set_header("X-Image-Height", image.height.to_s)

      # Return the image as binary data (image/jpeg)
      send_data image_buffer, type: "image/#{result_format}", disposition: "inline; filename=\"#{get_file_name_without_extension(url)}.#{result_format}\""

    rescue ImageTransformHelper::InvalidResizeLimitsError => e
      render json: { error: e.message }, status: :unprocessable_entity
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

  def fetch_remote_image(url)
    cached_response = self.class.fetch_remote_image_cache(url)
    return cached_response if cached_response.present?

    response_body = String.new(encoding: Encoding::BINARY)
    response = Faraday.get(url) do |request|
      next unless request&.respond_to?(:options)

      request.options.on_data = proc do |chunk, bytes_received, _env|
        raise RemoteImageTooLargeError if bytes_received > MAX_RESPONSE_SIZE

        response_body << chunk
      end
    end

    response_body = response.body if response_body.empty? && response.body.present?
    raise RemoteImageTooLargeError if response_body.bytesize > MAX_RESPONSE_SIZE

    normalized_response = {
      status: response.respond_to?(:status) ? response.status.to_i : 200,
      headers: response.headers.to_h,
      body: response_body
    }

    if cacheable_remote_image?(normalized_response)
      self.class.write_remote_image_cache(
        url,
        status: normalized_response[:status],
        headers: normalized_response[:headers],
        body: normalized_response[:body]
      )
    end

    normalized_response
  end

  def cacheable_remote_image?(response)
    response[:status].between?(200, 299) &&
      response[:headers]["content-type"].to_s.start_with?("image/") &&
      response[:body].present?
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
