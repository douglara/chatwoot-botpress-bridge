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
end
