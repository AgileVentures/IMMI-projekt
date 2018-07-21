class ShortenUrl

  SHORTEN_URL_LOG = 'log/tinyurl.log'
  SUCCESS_CODES = [200, 201, 202].freeze

  def self.short(url)
    response = HTTParty.get("http://tinyurl.com/api-create.php?url=#{url}")
    raise HTTParty::Error if response.match?(/error/i) || !SUCCESS_CODES.include?(response.code)
    response
  rescue HTTParty::Error => error
    ActivityLogger.open(SHORTEN_URL_LOG, 'TINYURL_API', 'shortening url', false) do |log|
      log.record('error', "Exception: #{error.message}")
      log.record('error', "Attempted URL: #{url}")
      log.record('error', "Response body: #{response.body}")
      log.record('error', "HTTP code: #{response.code}")
    end
    nil
  end
end

