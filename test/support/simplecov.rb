# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.command_name 'MiniTest'
SimpleCov.start 'rails' do
  add_filter '/test/'
  formatter SimpleCov::Formatter::MultiFormatter.new([
                                                       SimpleCov::Formatter::JSONFormatter,
                                                       SimpleCov::Formatter::HTMLFormatter
                                                     ])
end
