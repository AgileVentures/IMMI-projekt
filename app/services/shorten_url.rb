class ShortenUrl

  SHORTEN_URL_LOG = 'log/tinyurl.log'

  def self.short(url)
    response = HTTParty.get("http://tinyurl.com/api-create.php?url=#{url}")
    raise HTTParty::Error.new response if response.match? 'ERROR'
    response
  rescue HTTParty::Error => error
    ActivityLogger.open(SHORTEN_URL_LOG, 'TINYURL_API', 'shortening url', false) do |log|
      log.record('error', error.message)
    end 
    nil
  end
end

