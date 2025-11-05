module Botpress::Cloud::ResponseHandler
  def success_response(response, body)
    response.status == 200 && body.dig("code").blank? && body.dig("type").blank?
  end

  def failed_response_message(response, body)
    if response.status == 200 && body.dig("code") == 404 && body.dig("type") == "ResourceNotFound"
      { message: 'Invalid botpress cloud webhook token' }
    elsif response.status == 401 && body.dig("code") == 401 && body.dig("type") == "Unauthorized"
      { message: 'Invalid botpress cloud user token' }
    else
      { message: 'Invalid botpress endpoint' }
    end
  end
end
