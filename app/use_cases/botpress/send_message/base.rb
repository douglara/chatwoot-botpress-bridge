class Botpress::SendMessage::Base < Micro::Case
  attributes :event
  attributes :botpress_endpoint

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

  private

  def log_response_infos(response)
    Rails.logger.info("Botpress response")
    Rails.logger.info("Status code: #{response.status}")
    Rails.logger.info("Body: #{response.body}")
  end
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
