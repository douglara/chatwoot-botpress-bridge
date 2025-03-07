Faraday.default_connection = Faraday.new do |faraday|
  faraday.response :logger, Rails.logger, bodies: true
end
