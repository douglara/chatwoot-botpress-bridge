require 'faraday'

class Chatwoot::ValidEvent < Micro::Case
  attributes :event

  def call!
    if (
      event['event'] == 'message_created' &&
      event['message_type'] == 'incoming' &&
      valid_status?(event['conversation']['status'])
    ) || (
      event['event'] == 'message_updated' &&
      event['message_type'] == 'outgoing' &&
      event['content_type'] == 'input_select' &&
      event['content_attributes']['submitted_values'].respond_to?(:first)
    )
      Success result: { event: event }
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