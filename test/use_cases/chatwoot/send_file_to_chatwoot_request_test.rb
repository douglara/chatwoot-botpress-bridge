require "test_helper"

class SendFileToChatwootRequestTest < ActionDispatch::IntegrationTest
  setup do
    @service = Chatwoot::SendFileToChatwootRequest.send(:new, {})
  end

  test "should return valid file name" do
    result = @service.get_file_name_by_url('https://app.botpress.zimobi.com.br/api/v1/bots/teste-file/media/42rghrwr2zndfjw3fn4q-C%C3%B3pia%20de%20Wo%20(1024%C2%A0%C3%97%C2%A01024%C2%A0px)%20(2).png')
    assert_equal result, 'C%C3%B3pia%20de%20Wo%20(1024%C2%A0%C3%97%C2%A01024%C2%A0px)%20(2).png'
  end

  test "should throw invalid file name error" do
    assert_raises "Invalid file name" do
      @service.get_file_name_by_url('https://app.botpress.zimobi.com.br/api/v1/bots/teste-file/media/42rghrwr2zndfjw3fn4q_C%C3%B3pia%20de%20Wo%20(1024%C2%A0%C3%97%C2%A01024%C2%A0px)%20(2).png')
    end
  end
end