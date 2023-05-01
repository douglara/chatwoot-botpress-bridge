require 'faraday'

class Flow::ValidWebhook < Micro::Case
  attributes :chatwoot_webhook

  def call!
    if ( 
      chatwoot_webhook['event'] == 'message_created' &&
      chatwoot_webhook['message_type'] == 'incoming' &&
      valid_status?(chatwoot_webhook['conversation']['status'])
    )
      Success result: {chatwoot_webhook: chatwoot_webhook}
    else
      Failure result: { message: 'Invalid event' }
    end
  end

  def valid_status?(status)
    if ENV['CHATWOOT_ALLOWED_STATUSES'].present?
      allowed_statuses = ENV['CHATWOOT_ALLOWED_STATUSES'].split(',')
    else
      allowed_statuses = %w[pending]
    end

    allowed_statuses.include?(status)
  end
end