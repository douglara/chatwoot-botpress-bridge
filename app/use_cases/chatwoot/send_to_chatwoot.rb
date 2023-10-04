require 'faraday'
require 'uri'
require 'net/http'
require 'openssl'
require 'mimemagic'

class Chatwoot::SendToChatwoot < Micro::Case
  attributes :event
  attribute :botpress_response

  def call!
    account_id = event['account']['id']
    conversation_id = event['conversation']['id']
    chatwoot_endpoint = event['chatwoot_endpoint'] || ENV['CHATWOOT_ENDPOINT']
    chatwoot_bot_token = event['chatwoot_bot_token'] || ENV['CHATWOOT_BOT_TOKEN']

    if response_image?(botpress_response) || response_file?(botpress_response) || response_video?(botpress_response)
      request_url = "#{chatwoot_endpoint}/api/v1/accounts/#{account_id}/conversations/#{conversation_id}/messages"

      file_url = botpress_response['image'] || botpress_response['file'] || botpress_response['video']
      incoming_file_name = File.basename(file_url)
      real_file_name = incoming_file_name.sub(/^[^-]+-/, '')
      file_path = "temp_files/#{real_file_name}"
      download_file(file_url, file_path)

      url = URI(request_url)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request['api_access_token'] = chatwoot_bot_token

      file = File.open(file_path)
      file_mime_type = MimeMagic.by_path(file_path)

      form_data = [
        ['attachments[]', file, { content_type: file_mime_type }],
        ['content', botpress_response['title']]
      ]

      request.set_form(form_data, 'multipart/form-data')
      response = http.request(request)

      if response.code == 200
        Success result: JSON.parse(response.body)
      elsif response.code == 404 && response.body.include?('Resource could not be found')
        Failure result: { message: 'Chatwoot resource could not be found' }
      elsif response.code == 404
        Failure result: { message: 'Invalid chatwoot endpoint' }
      elsif response.code == 401
        Failure result: { message: 'Invalid chatwoot access token' }
      else
        Failure result: { message: 'Chatwoot server error' }
      end
    elsif response_choice_options?(botpress_response)
      Chatwoot::SendToChatwootRequest.call(
        account_id: account_id, conversation_id: conversation_id,
        chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
        body: build_choice_options_body(botpress_response)
      )
    else
      Chatwoot::SendToChatwootRequest.call(
        account_id: account_id, conversation_id: conversation_id,
        chatwoot_endpoint: chatwoot_endpoint, chatwoot_bot_token: chatwoot_bot_token,
        body: { content: botpress_response['text'] }
      )
    end
  end

  def response_image?(response)
    response['type'] == 'image'
  end

  def response_file?(response)
    response['type'] == 'file'
  end

  def response_video?(response)
    response['type'] == 'video'
  end

  def response_choice_options?(response)
    response['type'] == 'single-choice'
  end

  def build_choice_options_body(botpress_response)
    {
      content: botpress_response['text'],
      content_type: 'input_select',
      content_attributes: {
        items: botpress_response['choices'].map {
          | option |
            {
              title: option['title'],
              value:  option['value']
            }
        }
      }
    }
  end

  def download_file(file_url, file_path)
    file = Faraday.get(file_url).body

    File.write(file_path, file, mode: 'wb', encoding: 'ASCII-8BIT')
  end
end