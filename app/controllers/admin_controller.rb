class AdminController < ApplicationController
  before_action :authenticate

  def authenticate
    authenticate_or_request_with_http_basic('Administration') do |email, password|
      email == ENV.fetch("ADMIN_USER") { 'lovebridge' } && password == ENV.fetch("ADMIN_PASSWORD") { 'lovebridge' }
    end
  end
end
