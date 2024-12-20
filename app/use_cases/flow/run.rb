require 'faraday'

class Flow::Run < Micro::Case
  flow Flow::ValidWebhook,
  Flow::ProcessWebhook
end