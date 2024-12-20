class ChatwootController < ApplicationController
  def webhook
    Chatwoot::ReceiveEventJob.perform_later(params.to_json)
  end
end
