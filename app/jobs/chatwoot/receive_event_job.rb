require 'faraday'

class Chatwoot::ReceiveEventJob < ApplicationJob

  def perform(params)
    Chatwoot::ReceiveEvent.call(event: JSON.parse(params))
  end
end
