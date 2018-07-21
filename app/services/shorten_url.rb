class ShortenUrl

  SHORTEN_URL_LOG = 'log/tinyurl.log'
  SUCCESS_CODES = [200, 201, 202].freeze

  def self.short(url)
    response = HTTParty.get("http://tinyurl.com/api-create.php?url=#{url}")
    raise HTTParty::Error if response.match?(/error/i) || !SUCCESS_CODES.include?(response.code)
    response
  rescue HTTParty::Error => error
    log_error(error)
    nil
  end

  private_class_method

  def self.log_error(error)
    ActivityLogger.open(SHORTEN_URL_LOG, 'TINYURL_API', 'shortening url', false) do |log|
      log.record('error', "Exception: #{error.message}")
      if response
        log.record('error', "Attempted URL: #{url}")
        log.record('error', "Response body: #{response.body}")
        log.record('error', "HTTP code: #{response.code}")
      else
        log.record('error', "Exception raised by HTTParty")
      end
    end
  end
end

