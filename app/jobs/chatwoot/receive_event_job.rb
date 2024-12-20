require 'faraday'

class Chatwoot::ReceiveEventJob < ApplicationJob

  def perform(params)
    Flow::Run.call(chatwoot_webhook: JSON.parse(params))
  end
end
