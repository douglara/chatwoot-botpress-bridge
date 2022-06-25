class ChatwootController < ApplicationController
  def webhook
    result = Chatwoot::ReceiveEvent.call(params)
    render json: result
  end
end
