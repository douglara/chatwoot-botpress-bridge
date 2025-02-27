class PagesController < ApplicationController

  def home
    send_file Rails.root.join('public', 'home.html'), type: 'text/html; charset=utf-8', disposition: 'inline'
  end
end
