require "test_helper"

class BotpressTest < ActiveSupport::TestCase
  class HostType < BotpressTest
    test "returns :cloud for main botpress cloud domain" do
      url = "https://botpress.cloud"
      assert_equal :cloud, Botpress.host_type(url)
    end

    test "returns :cloud for subdomain under botpress.cloud" do
      url = "https://chat.botpress.cloud/d15a0a6c-d3be-419d-846a-240edbfe2646"
      assert_equal :cloud, Botpress.host_type(url)
    end

    test "returns :self_hosted for custom domains" do
      url = "https://my-botpress.example.com"
      assert_equal :self_hosted, Botpress.host_type(url)
    end

    test "returns :self_hosted for localhost" do
      url = "http://localhost:3000"
      assert_equal :self_hosted, Botpress.host_type(url)
    end

    test "returns :invalid when URL is malformed" do
      url = "not_a_valid_url"
      assert_equal :invalid, Botpress.host_type(url)
    end

    test "returns :invalid when host is nil" do
      url = ""
      assert_equal :invalid, Botpress.host_type(url)
    end
  end
end
