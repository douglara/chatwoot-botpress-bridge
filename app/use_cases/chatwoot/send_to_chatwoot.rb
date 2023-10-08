require 'net/http'
require 'openssl'
require 'uri'
require 'open-uri'

class Chatwoot::SendToChatwoot < Micro::Case
  attributes :event
  attribute :botpress_response

  def call!
    account_id = event['account']['id']
    conversation_id = event['conversation']['id']
    chatwoot_endpoint = event['chatwoot_endpoint'] || ENV['CHATWOOT_ENDPOINT']
    chatwoot_bot_token = event['chatwoot_bot_token'] || ENV['CHATWOOT_BOT_TOKEN']

    if response_image?(botpress_response) || response_file?(botpress_response) || response_video?(botpress_response)
      file_url = botpress_response['image'] || botpress_response['file'] || botpress_response['video']
      file_name = get_file_name_by_url(file_url)
      file = download_file(file_url)

      url = URI("#{chatwoot_endpoint}/api/v1/accounts/#{account_id}/conversations/#{conversation_id}/messages")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request['api_access_token'] = chatwoot_bot_token

      form_data = [
        ['content', botpress_response['title']],
        ['attachments[]', file, { filename: file_name , content_type: file.content_type }]
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

  def download_file(file_url)
    OpenURI::open_uri(file_url)
  end

  def get_file_name_by_url(file_url)
    incoming_file_name = File.basename(file_url)
    incoming_file_name.sub(/^[^-]+-/, '')
  end
end