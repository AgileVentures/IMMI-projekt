# ----------------------------------------------------------------
#
# @class ExternalHTTPService
#
# @desc Responsibility:  Get a response from an external service via HTTParty
#
#   Provides the sequence of steps required to get a response and handle errors
#   with opportunities (hooks) for subclasses to override and control specific
#   parts.
#   (The "template method" pattern http://www.oodesign.com/template-method-pattern.html)
#
#   Subclasses *must* provide:
#     - the url for the external service to get the response  (provided via def self.response_url(*args) )
#
#   Subclasses can optionally override:
#     - self.response_headers(*_args)
#         Header information provided to the external service when getting the response from it
#     - self.return_immediately?(response)
#         Will cause the get_response method to return immediately after
#         receiving a response that == the response parameter
#         (No processing will happen to the response)
#         The default behavior defined in this class is to return immediately if the response is 'succeessful'
#     - self.process(response)
#         Do whatever needs to be done with the response
#         Default behavior in this class is to do nothing
#     - self.return_after_processing?(_processed_response)
#         Whether or not the get_response method should return after processing the response
#     - self.set_error(processed_response)
#         Get error information from the processed_response
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2017
# @file   app/services/external_http_service.rb
#
# ----------------------------------------------------------------#
class ExternalHTTPService

  require 'httparty'

  SUCCESS_CODES = [200, 201, 202].freeze

  # subclasses can just override the 'get_ ...' methods or they can
  # override this method completely
  def self.get_response(*args)

    response = HTTParty.get(response_url(args),
                            headers: response_headers(args))

    begin
      # return  (do not do any processing)
      return response.parsed_response if return_immediately?(response)
    rescue => err
      rescue_parsed_response err
    end

    processed_response = process(response)

    return processed_response if return_after_processing?(processed_response)

    error = set_error(processed_response)

    begin
      raise "Error: #{error['type']}, #{error['message']}"
    rescue RuntimeError
      raise "HTTP Status: #{response.code}, #{response.message}"
    end

  end


  # child classes MUST override this
  # @param args [Array] - arguments passed in to self.get_item so that they are all available as needed for any subclass that overrides this method
  # @return [String] the url that will be sent to HTTParty to get the response
  def self.response_url(*_args)
    raise ::NotImplementedError, "You must define the 'response_url' class method."
  end


  # child classes can override as needed
  # @param args [Array] - arguments passed in to self.get_item so that they are all available as needed for any subclass that overrides this method
  # @return [Hash]  headers that must be explicitly set
  def self.response_headers(*_args)
    {}
  end


  # child classes can override as needed
  #
  # If needed, this can test the response immediately after it is received.
  # Return true if the calling method should return immediately after this is called
  # Default behavior defined in this class is to return immediately if the response is 'successful'
  # Subclasses may want to check different codes or use a more complicated condition
  #
  # @return [Boolean]
  def self.return_immediately?(response)
    response.respond_to?(:code) && SUCCESS_CODES.include?(response.code)
  end


  # opportunity to do something with the response
  # child classes can override this as needed
  def self.process(response)
    response
  end


  # child classes can override as needed
  #
  # An opportunity for a child class to do something when the rescue block
  # is executed after reaponse.parsed_response
  # Ex:  A subclass may want to override this and raise the err
  def self.rescue_parsed_response(_err)
    # do nothing by default
  end


  # child classes can override as needed
  #
  # If needed, this can test the response immediately after it is received.
  # Return true if the calling method should return immediately after this is called
  # @return [Boolean]
  def self.return_after_processing?(_processed_response)
    false
  end


  # child classes can override as needed
  #
  # @return error information that can be used if an Error is raised
  def self.set_error(processed_response)
    processed_response.nil? ? nil : processed_response.fetch('error', nil)
  end

end
