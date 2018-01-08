# Interface to Dinkurs.se
# https://dinkurs.se

require 'date'


class DinkursService < ExternalHTTPService


  # required by the parent class
  # URL that we'll get the info from
  #
  # the dinkurs_company_id is the only argument passed in
  def self.response_url(*args)
    DINKURS_XML_URL + '?' + DINKURS_COMPANY_ARG + "=#{args[0][0]}"
  end


  # Return a collection of all events for this Dinkurs company id
  #  will return an empty collection if there are no events from Dinkurs
  #   (which may be the case if the company id is not recognized by Dinkurs)
  #
  # This can be called by a controller (for example).
  #
  def self.get_events(dinkurs_company_id)

    # TODO how to return an error status to signal that something went very wrong?
      #  begin... rescue...ensure ?

    dk_events = []

    xml_event_response = self.get_response(dinkurs_company_id)

    unless xml_event_response['events'].nil?

      xml_event_response['events'].fetch('event', []).each do |event|
        dk_events << DinkursEvent.new_from_event_hash(event)
      end

    end

    dk_events

  end




end
