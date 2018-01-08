class DinkursEvent < ApplicationRecord

  belongs_to :company

  validates_presence_of :dinkurs_id
  validates_presence_of :name
  validates_presence_of :start
  validates_presence_of :key
  validates_presence_of :url_id
  validates_presence_of :url_key


  DK_CONTENT_KEY = '__content__'    # used in DinKurs XML data


  def self.new_from_event_hash(event_hash)

    dk = self.new({ dinkurs_id: event_hash['event_id'].first,
                    name: key_content(event_hash, 'event_name'),
                    place: key_content(event_hash, 'event_place'),
                    place_geometry_location: key_content(event_hash, 'event_place_geometry_location'),
                    host: key_content(event_hash, 'event_host'),

                    fee: key_content(event_hash, 'event_fee'),
                    fee_tax: key_content(event_hash, 'event_fee_tax'),
                    pub: key_content(event_hash, 'event_pub'),

                    apply: key_content_date(event_hash, 'event_apply'),
                    start: key_content_date(event_hash, 'event_start'),
                    stop: key_content_date(event_hash, 'event_stop'),

                    participant_number: key_content(event_hash, 'event_participant_number'),
                    participant_reserve: key_content(event_hash, 'event_participant_reserve'),

                    participants: key_content(event_hash, 'event_participants'),

                    occasions: key_content(event_hash, 'event_occasions'),
                    group: key_content(event_hash, 'event_group'),

                    position: key_content(event_hash, 'event_position'), # number
                    instructor_1: key_content(event_hash, 'event_instructor_1'),
                    instructor_2: key_content(event_hash, 'event_instructor_2'),
                    instructor_3: key_content(event_hash, 'event_instructor_3'),

                    infotext: key_content(event_hash, 'event_infotext'),
                    commenttext: key_content(event_hash, 'event_commenttext'),

                    ticket_info: key_content(event_hash, 'event_ticket_info'),

                    key: key_content(event_hash, 'event_key'),
                    url_id: key_content(event_hash, 'event_url_id'),
                    url_key: key_content(event_hash, 'event_url_key'),

                    completion_text: key_content(event_hash, 'event_completion_text'),
                    aftertext: key_content(event_hash, 'event_aftertext'),

                    dates: key_content(event_hash, 'event_dates'),
                  })
    dk

  end

  # get the value from a hash that has the form
  #  key => DK_CONTENT_KEY => value
  #
  # This is the form returned from DinKurs.se xml:
  #  'some_key' => { DK_CONTENT_KEY => some_value }
  #
  # constant defined for this = DK_CONTENT_KEY
  #
  # @return nil if the key isn't there;
  #                return nil if DK_CONTENT_KEY isn't there,
  #                else return the value found at ['some_key'][DK_CONTENT_KEY]
  def self.key_content(event_hash, key)
    key_value = event_hash.fetch(key, nil)
    key_value.nil? ? nil : key_value.fetch(DK_CONTENT_KEY, nil)
  end


  # get the key_content and, if it's not nil, convert it to a Date
  def self.key_content_date(event_hash, key)
    value = key_content(event_hash, key)
    (!value.nil? && value.is_a?(String)) ? Date.parse(value) : nil
  end


end
