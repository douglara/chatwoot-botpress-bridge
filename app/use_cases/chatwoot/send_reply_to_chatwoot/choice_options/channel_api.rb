class Chatwoot::ChoiceOptions::ChannelApi < Micro::Case
  flow  Chatwoot::ChoiceOptions::ConvertToText,
        Chatwoot::SendReplyToChatwoot::Request
end