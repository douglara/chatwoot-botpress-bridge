require 'faraday'

class Botpress::SendToBotpress < Micro::Case
  attributes :event
  attributes :botpress_endpoint
  attributes :botpress_bot_id

  # Event {
  #   'conversation' => {
  #     'id' => String
  #     ...
  #   }
  #   'content' => NilableString
  #   'attachments' => Array<Attachment>
  #   ...
  # }

  # Attachment {
  #   'file_type' => String
  #   ...
  # }

  def call!
    conversation_id = event['conversation']['id']
    message_content = event_message_content(event)
    url = "#{botpress_endpoint}/api/v1/bots/#{botpress_bot_id}/converse/#{conversation_id}"

    body = {
      'text': "#{message_content}",
      'type': 'text',
      'metadata': {
        'event': event
      }
    }

    response = Faraday.post(url, body.to_json, {'Content-Type': 'application/json'})

    Rails.logger.info("Botpress response")
    Rails.logger.info("Status code: #{response.status}")
    Rails.logger.info("Body: #{response.body}")

    if (response.status == 200)
      Success result: JSON.parse(response.body)
    elsif (response.status == 404 && response.body.include?('Invalid Bot ID'))
      Failure result: { message: 'Invalid Bot ID' }
    else
      Failure result: { message: 'Invalid botpress endpoint' }
    end
  end

  private

  # : (Event) -> String
  def event_message_content(event)
    content, attachments = event.values_at('content', 'attachments')

    return content if content.present? || attachments.blank?

    map_attachments_to_message_content(attachments)
  end

  # : (Array<Attachment>) -> String
  def map_attachments_to_message_content(attachments)
    attachments
      .map { |attachment| map_attachment_to_message_content(attachment) }
      .join(' ')
  end

  # : (Attachment) -> String
  def map_attachment_to_message_content(attachment)
    "/#{attachment['file_type']}"
  end
end
