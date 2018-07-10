class TinyURL
  def self.short(url)
    HTTParty.get("http://tinyurl.com/api-create.php?url=#{url}")
  end
end

