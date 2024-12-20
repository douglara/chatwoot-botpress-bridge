ENV["RAILS_ENV"] ||= "test"
require_relative "./support/simplecov"
require_relative "../config/environment"
require "rails/test_help"
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |rb| require(rb) }
require 'webmock/minitest'
require 'minitest/mock'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  def mock_env(partial_env_hash)
    old = ENV.to_hash
    ENV.update partial_env_hash
    begin
      yield
    ensure
      ENV.replace old
    end
  end

  def with_logger_introspection(&block)
    orig_logger = Rails.logger.dup
    @logger_output = StringIO.new
    begin
      Rails.logger = ActiveSupport::Logger.new(@logger_output)
      block.call(@logger_output)
    ensure
      Rails.logger = orig_logger
    end
  end
end
