class Chatwoot::SendReplyToChatwoot::ChoiceOptions::ConvertToText < Micro::Case
  attribute :botpress_response

  def call!
    Success result: { content: build_text() }
  end

  def build_text()
    options = botpress_response['choices'].map.with_index do | option, index |
      "#{index + 1} - #{option['title']}"
    end

    return "#{botpress_response['text']}\n\n#{options.join("\n")}"
  end
end