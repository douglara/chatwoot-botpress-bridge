require 'faraday'

class Botpress::ReceiveEventJob < ApplicationJob
  def perform(params)
    Botpress::ReceiveEvent.call(event: JSON.parse(params))
  end
end
