require 'net/http'
require 'openssl'
require 'uri'
require 'open-uri'

class Chatwoot::SendFileToChatwootRequest < Micro::Case
  attributes :account_id
  attributes :conversation_id
  attribute :botpress_response

  attributes :chatwoot_endpoint
  attributes :chatwoot_bot_token

  def call!
    file_url = botpress_response['image'] || botpress_response['file'] || botpress_response['video']
    file_name = get_file_name_by_url(file_url)
    file = download_file(file_url)

    url = URI("#{chatwoot_endpoint}/api/v1/accounts/#{account_id}/conversations/#{conversation_id}/messages")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request['api_access_token'] = chatwoot_bot_token

    form_data = [['attachments[]', file, { filename: file_name , content_type: file.content_type }]]

    unless botpress_response['title'].nil?
      form_data << ['content', botpress_response['title']]
    end

    request.set_form(form_data, 'multipart/form-data')
    response = http.request(request)

    Rails.logger.info("Chatwoot response")
    Rails.logger.info("Status code: #{response.code}")
    Rails.logger.info("Body: #{response.body}")

    if response.code == "200"
      Success result: JSON.parse(response.body)
    elsif response.code == "404" && response.body.include?('Resource could not be found')
      Failure result: { message: 'Chatwoot resource could not be found' }
    elsif response.code == "404"
      Failure result: { message: 'Invalid chatwoot endpoint' }
    elsif response.code == "401"
      Failure result: { message: 'Invalid chatwoot access token' }
    else
      Failure result: { message: 'Chatwoot server error' }
    end
  end

  def download_file(file_url)
    begin
      OpenURI::open_uri(file_url)
    rescue
      raise "File url is invalid"
    end
  end

  def get_file_name_by_url(file_url)
    incoming_file_name = File.basename(file_url)
    raise "Invalid file name" unless incoming_file_name.include?('-')
    incoming_file_name.sub(/^[^-]+-/, '')
  end
end
