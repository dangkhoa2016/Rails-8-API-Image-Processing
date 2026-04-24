Faraday.default_connection = Faraday.new do |f|
  f.options.timeout      = 10
  f.options.open_timeout = 10
end
