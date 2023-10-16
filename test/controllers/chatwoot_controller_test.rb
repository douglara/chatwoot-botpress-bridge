require "test_helper"

class ChatwootControllerTest < ActionDispatch::IntegrationTest
  test "success" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Testing","markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post,  Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":64374,"content":"Testing","inbox_id":10,"conversation_id":11791,"message_type":1,"content_type":"text","content_attributes":{},"created_at":1656268790,"private":false,"source_id":null,"sender":{"id":3,"name":"Botpress Testing","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    body = File.read(Rails.root + "test/fixtures/files/new_message.json")
    post chatwoot_webhook_url, params: body, headers: { "Content-Type": "application/json" }
    assert_response :success
  end

  test "with dynamic botpress bot id" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
    to_return(status: 200, body: '{"responses":[{"type":"text","workflow":{},"text":"Testing","markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})
    stub_request(:post,  Regexp.new(ENV['CHATWOOT_ENDPOINT'])).
    to_return(status: 200, body: '{"id":64374,"content":"Testing","inbox_id":10,"conversation_id":11791,"message_type":1,"content_type":"text","content_attributes":{},"created_at":1656268790,"private":false,"source_id":null,"sender":{"id":3,"name":"Botpress Testing","avatar_url":"","type":"agent_bot"}}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    body = JSON.parse(File.read(Rails.root + "test/fixtures/files/new_message.json"))
    body.merge!({ "botpress_bot_id" => "test123" })

    post chatwoot_webhook_url, params: body.to_json, headers: { "Content-Type": "application/json" }
    assert_response :success
  end

  test "should send image" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
      to_return(status: 200, body: '{"responses":[{"type":"image","workflow":{},"image":"https://app.botpress.zimobi.com.br/api/v1/bots/teste-file/media/42rghrwr2zndfjw3fn4q-C%C3%B3pia%20de%20Wo%20(1024%C2%A0%C3%97%C2%A01024%C2%A0px)%20(2).png","title":"Texto da imagem de teste","typing":true},{"type":"text","workflow":{},"text":"Bye!","markdown":true,"typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    stub_request(:get, Regexp.new(/api\/v1\/bots\/teste-file\/media/)).
      to_return(status: 200, body: File.read(Rails.root + 'test/fixtures/files/image-file.png'), headers: {'Content-Type': 'image/png'})

    stub_request(:post, /messages/).
      to_return(status: 200, body: '{"id":332180,"content":"Texto da imagem de teste","inbox_id":73,"conversation_id":24,"message_type":1,"content_type":"text","status":"sent","content_attributes":{},"created_at":1696877253,"private":false,"source_id":null,"sender":{"id":13,"name":"Bot File local","avatar_url":"","type":"agent_bot"},"attachments":[{"id":17524,"message_id":332180,"file_type":"image","account_id":19,"extension":null,"data_url":"https://chat.zimobi.com.br/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBa2ZQIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--b40880556adb1d59d7920e57dcd01177c6d6d003/C%C3%B3pia%20de%20Wo%20(1024%C2%A0%C3%97%C2%A01024%C2%A0px)%20(2).png","thumb_url":"https://chat.zimobi.com.br/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBa2ZQIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--b40880556adb1d59d7920e57dcd01177c6d6d003/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJY0c1bkJqb0dSVlE2RTNKbGMybDZaVjkwYjE5bWFXeHNXd2RwQWZvdyIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--ca4751066a2e1a2af79f9cc6d5fa306d7d1c71cb/C%C3%B3pia%20de%20Wo%20(1024%C2%A0%C3%97%C2%A01024%C2%A0px)%20(2).png","file_size":65733}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    body = JSON.parse(File.read(Rails.root + "test/fixtures/files/new_message.json"))

    post chatwoot_webhook_url, params: body.to_json, headers: { "Content-Type": "application/json" }
    assert_response :success
    assert_match /file_type"=>"image/, JSON.parse(response.body)['chatwoot_responses'].to_s
    assert_match /content"=>"Texto da imagem de teste/, JSON.parse(response.body)['chatwoot_responses'].to_s
  end

  test "should send video" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
      to_return(status: 200, body: '{"responses":[{"type":"video", "workflow":{}, "video":"https://app.botpress.zimobi.com.br/api/v1/bots/teste-file/media/oj3s5liagedo2bmaaddy-video-test.mp4", "title":"titulo video teste", "typing":true}, {"type":"text", "workflow":{}, "text":"Bye!", "markdown":true, "typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    stub_request(:get, Regexp.new(/api\/v1\/bots\/teste-file\/media/)).
      to_return(status: 200, body: File.read(Rails.root + 'test/fixtures/files/video-file.mp4'), headers: {'Content-Type': 'video/mp4'})

    stub_request(:post, /messages/).
      to_return(status: 200, body: '{"id":332201,"content":"titulo video teste","inbox_id":73,"conversation_id":24,"message_type":1,"content_type":"text","status":"sent","content_attributes":{},"created_at":1696877453,"private":false,"source_id":null,"sender":{"id":13,"name":"Bot File local","avatar_url":"","type":"agent_bot"},"attachments":[{"id":17527,"message_id":332201,"file_type":"video","account_id":19,"extension":null,"data_url":"https://chat.zimobi.com.br/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBa3ZQIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--4565cf175fec254c76c622b336df6f89d5473527/video-test.mp4","thumb_url":"","file_size":0}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    body = JSON.parse(File.read(Rails.root + "test/fixtures/files/new_message.json"))

    post chatwoot_webhook_url, params: body.to_json, headers: { "Content-Type": "application/json" }
    assert_response :success
    assert_match /file_type"=>"video/, JSON.parse(response.body)['chatwoot_responses'].to_s
    assert_match /content"=>"titulo video teste/, JSON.parse(response.body)['chatwoot_responses'].to_s
  end

  test "should send file" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
      to_return(status: 200, body: '{"responses":[{"type":"file", "workflow":{}, "file":"https://app.botpress.zimobi.com.br/api/v1/bots/teste-file/media/nmb8ifmr423ugq4xox4d-a.pdf", "typing":true}, {"type":"text", "workflow":{}, "text":"Bye!", "markdown":true, "typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    stub_request(:get, Regexp.new(/api\/v1\/bots\/teste-file\/media/)).
      to_return(status: 200, body: File.read(Rails.root + 'test/fixtures/files/pdf-file.pdf'), headers: {'Content-Type': 'application/pdf'})

    stub_request(:post, /messages/).
      to_return(status: 200, body: '{"id":337821,"content":null,"inbox_id":73,"conversation_id":25,"message_type":1,"content_type":"text","status":"sent","content_attributes":{},"created_at":1696959105,"private":false,"source_id":null,"sender":{"id":13,"name":"Bot File local","avatar_url":"","type":"agent_bot"},"attachments":[{"id":17855,"message_id":337821,"file_type":"file","account_id":19,"extension":null,"data_url":"https://chat.zimobi.com.br/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBa0xSIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--64e0af67db22c6f8ec318fd11163ca5354e9ab61/a.pdf","thumb_url":"https://chat.zimobi.com.br/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBa0xSIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--64e0af67db22c6f8ec318fd11163ca5354e9ab61/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmtCK2pBPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--2942dc8de0003672434590effad890a9d0ca8a09/a.pdf","file_size":0}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    body = JSON.parse(File.read(Rails.root + "test/fixtures/files/new_message.json"))

    post chatwoot_webhook_url, params: body.to_json, headers: { "Content-Type": "application/json" }
    assert_response :success
    assert_match /file_type"=>"file/, JSON.parse(response.body)['chatwoot_responses'].to_s
    assert_match /content"=>nil/, JSON.parse(response.body)['chatwoot_responses'].to_s
  end

  test "should send file with message" do
    stub_request(:post, Regexp.new(ENV['BOTPRESS_ENDPOINT'])).
      to_return(status: 200, body: '{"responses":[{"type":"file", "workflow":{}, "file":"https://app.botpress.zimobi.com.br/api/v1/bots/teste-file/media/nmb8ifmr423ugq4xox4d-a.pdf", "title":"pdf teste", "typing":true}, {"type":"text", "workflow":{}, "text":"Bye!", "markdown":true, "typing":true}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    stub_request(:get, Regexp.new(/api\/v1\/bots\/teste-file\/media/)).
      to_return(status: 200, body: File.read(Rails.root + 'test/fixtures/files/pdf-file.pdf'), headers: {'Content-Type': 'application/pdf'})

    stub_request(:post, /messages/).
      to_return(status: 200, body: '{"id":336815,"content":"pdf teste","inbox_id":73,"conversation_id":25,"message_type":1,"content_type":"text","status":"sent","content_attributes":{},"created_at":1696953209,"private":false,"source_id":null,"sender":{"id":13,"name":"Bot File local","avatar_url":"","type":"agent_bot"},"attachments":[{"id":17814,"message_id":336815,"file_type":"file","account_id":19,"extension":null,"data_url":"https://chat.zimobi.com.br/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBdnJRIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--00e63700ad55f84724cddde66b187cc8475a6b0d/a.pdf","thumb_url":"https://chat.zimobi.com.br/rails/active_storage/representations/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBdnJRIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--00e63700ad55f84724cddde66b187cc8475a6b0d/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCam9UY21WemFYcGxYM1J2WDJacGJHeGJCMmtCK2pBPSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--2942dc8de0003672434590effad890a9d0ca8a09/a.pdf","file_size":0}]}', headers: {'Content-Type': 'application/json; charset=utf-8'})

    body = JSON.parse(File.read(Rails.root + "test/fixtures/files/new_message.json"))

    post chatwoot_webhook_url, params: body.to_json, headers: { "Content-Type": "application/json" }
    assert_response :success
    assert_match /file_type"=>"file/, JSON.parse(response.body)['chatwoot_responses'].to_s
    assert_match /content"=>"pdf teste/, JSON.parse(response.body)['chatwoot_responses'].to_s
  end
end
