class ChatwootController < ApplicationController
  def webhook
    Chatwoot::ReceiveEvent.call(event: params)
    .on_success { |result| render(200, json: result.data) }
    .on_failure { |result| render_json(500, json: result.data) }
  end
end
