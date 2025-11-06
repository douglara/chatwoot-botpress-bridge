# frozen_string_literal: true

class Botpress::Api::CloudClient < Micro::Case
  attributes :request_kind
  attributes :botpress_endpoint
  attributes :path
  attributes :request_body

  def call!
    endpoint = "#{botpress_endpoint}/#{wehook_token}#{path}"
    headers = request_headers
    request = Faraday.send(request_kind.downcase, endpoint, request_body, headers)

    Rails.logger.info("Botpress::Api::CloudClient request body: #{request_body}, response body: #{request.body} status: #{request.status}")

    validate_response(request)
  end

  private

  def wehook_token
    ENV.fetch('BOTPRESS_CLOUD_WEBHOOK_TOKEN', '')
  end

  def user_token
    ENV.fetch('BOTPRESS_CLOUD_USER_TOKEN', '')
  end

  def request_headers
    {'Content-Type': 'application/json', 'x-user-key': user_token}
  end

  def validate_response(request)
    body = JSON.parse(request.body)

    return Success(result: body) if success_response?(request, body)
    return Failure(result: { message: 'Invalid botpress cloud webhook token' }) if webhook_invalid_token?(request, body)
    return Failure(result: { message: 'Invalid botpress cloud user token' }) if authentication_error?(request, body)

    Failure(result: { message: 'Invalid botpress endpoint' })
  end

  def success_response?(request, body)
    request.status == 200 && body.dig("code").blank? && body.dig("type").blank?
  end

  def webhook_invalid_token?(request, body)
    request.status == 200 && body.dig("code") == 404 && body.dig("type") == "ResourceNotFound"
  end

  def authentication_error?(request, body)
    request.status == 401 && body.dig("code") == 401 && body.dig("type") == "Unauthorized"
  end
end
