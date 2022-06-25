require "vcr"

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = false
  config.cassette_library_dir = File.expand_path("../../vcr_cassettes", __FILE__)

  config.hook_into :webmock
  config.ignore_request { ENV["DISABLE_VCR"] }
  #config.ignore_localhost = true
  config.default_cassette_options = {
    :record => :new_episodes
  }
end

# Monkey patch the `test` DSL to enable VCR and configure a cassette named
# based on the test method. This means that a test written like this:
# 
# class OrderTest < ActiveSupport::TestCase
#   test "user can place order" do
#     ...
#   end
# end
# 
# will automatically use VCR to intercept and record/play back any external
# HTTP requests using `cassettes/order_test/_user_can_place_order.yml`.
# 
class ActiveSupport::TestCase
  def self.test(test_name, &block)
    return super if block.nil?
    location = block.source_location[0].split('test/')[1][0...-3].split('/')
 
    cassette =  location.append(test_name).map do |str|
      str.underscore.gsub(/[^A-Z]+/i, "_")
    end.join("/")

    super(test_name) do
      VCR.use_cassette(cassette) do
        instance_eval(&block)
      end
    end
  end
end