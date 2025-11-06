class BotpressController < ApplicationController
  def webhook
    Botpress::ReceiveEventJob.perform_later(params.to_json)
  end
end
