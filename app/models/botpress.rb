class Botpress
  def self.host_type(url)
    host = URI(url).host rescue nil
    return :invalid unless host

    if host == "botpress.cloud" || host.end_with?(".botpress.cloud")
      :cloud
    else
      :self_hosted
    end
  end

  def self.cloud_wehook_token
    ENV.fetch('BOTPRESS_CLOUD_WEBHOOK_TOKEN', '')
  end

  def self.cloud_user_token
    ENV.fetch('BOTPRESS_CLOUD_USER_TOKEN', '')
  end

  def self.cloud_request_headers
    {'Content-Type': 'application/json', 'x-user-key': cloud_user_token}
  end
end
