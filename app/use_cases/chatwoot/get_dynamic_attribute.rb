require 'faraday'

class Chatwoot::GetDynamicAttribute < Micro::Case
  attributes :event, :attribute

  def call!
    return Success result: { attribute: event['conversation']['custom_attributes'][attribute] } if event.dig('conversation', 'custom_attributes', attribute).present? 
    return Success result: { attribute: event[attribute] } if event[attribute].present?
    return Success result: { attribute: ENV[attribute.upcase] }
  end
end