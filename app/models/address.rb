class Address < ApplicationRecord
  # An address only exists within an owning object, called "addressable".
  # (right now this only exists as a Company address - user (member address
  #  possibly to be added later).
  # Thus the model behavior is consistent with the business rules of the
  # Company model.  This is manifest in some of the Address controller actions.

  before_save :format_city_name

  belongs_to :addressable, polymorphic: true

  # When an address is initially created, it may not have a kommun or region assigned,
  # for example when an admin creates a company but doesn't have all of the info for the main address.
  belongs_to :region, optional: true

  belongs_to :kommun, optional: true

  validates :addressable, :country, :street_address, :post_code, :city,
            presence: true

  # Business rule: addressable (business, member) can have only one mailing address
  validates_uniqueness_of :mail, scope: :addressable_id,
                          conditions: -> { where(mail: true) },
                          if: proc { :mail }

  NO_VISIBILITY = 'none'
  MAX_VISIBILITY = 'street_address'
  ADDRESS_VISIBILITY = [MAX_VISIBILITY, 'post_code', 'city', 'kommun', NO_VISIBILITY]
  VISIBILITY_ITEMS = ADDRESS_VISIBILITY - [NO_VISIBILITY]

  validates :visibility, inclusion: ADDRESS_VISIBILITY

  scope :has_region, -> { where('region_id IS NOT NULL') }

  scope :lacking_region, -> { where('region_id IS NULL') }

  scope :visible, -> { where.not(visibility: NO_VISIBILITY) }

  scope :mail_address, -> { where(mail: true) }

  scope :company_address, -> { where(addressable_type: 'Company') }

  geocoded_by :entire_address

  GEO_FIELDS = %w(street_address post_code city kommun_id
                  region_id visibility country).freeze

  after_validation :geocode_best_possible,
                   if: ->(obj) {
                          obj.new_record? ||
                          (obj.latitude.nil? || obj.longitude.nil?) ||
                          (obj.changed_attribute_names_to_save &
                            GEO_FIELDS).any?
                   }


  # ---------------------------------------------------------------------------


  # geocode all of the addresses that need it
  #
  # sleep_between = number of seconds to sleep between each geocode call so
  #  that we don't go over the # requests per second of the service (ex Google)
  # num_per_batch = the number to fetch from the db per batch
  #
  def self.geocode_all_needed(sleep_between: 0.5, num_per_batch: 50)

    need_geocoding = self.not_geocoded # this method comes from Geocoder

    Geocoder.configure(timeout: 20) # geocoding service timeout (secs).
    # need this long to ensure we don't timeout

    need_geocoding.find_each(batch_size: num_per_batch) do |addr|
      addr.geocode_best_possible
      addr.save
      sleep(sleep_between.to_f)
    end

  end


  def self.address_visibility_levels
    ADDRESS_VISIBILITY
  end


  def self.max_visibility
    MAX_VISIBILITY
  end


  def self.no_visibility
    NO_VISIBILITY
  end


  def self.visibility_items
    VISIBILITY_ITEMS
  end

  # ----------------------------------------------------------------------------


  # TODO This should only be called for an address associated with a company
  #
  # @param [String] visibility_limit - the 'level' visibility to use
  #   default is the visibility set for this address
  #
  # @return [Array[String]] - an array of address field values (strings)
  #   that starts with the
  #   attribute associated with the visibility_limit set for this address.
  def address_array(visibility_limit = visibility)
    return [] if visibility_limit == self.class.no_visibility

    start_index = self.class.visibility_items.index { |viz_item| viz_item == visibility_limit }
    return [] unless start_index

    viz_items_length = self.class.visibility_items.length

    # Create the array with the actual values of the address.
    #  Add in the kommun name if there is one for the address.
    if kommun
      ary = [street_address, post_code, city, kommun.name,
             sverige_if_nil][start_index..viz_items_length]
    else
      ary = [street_address, post_code, city,
             sverige_if_nil][start_index..(viz_items_length - 1)]
    end
    ary.delete_if { |f| f.blank? }
  end


  ADDR_JOINER = ', '

  # @return [String] - the address elements, joined by ADDR_JOINER.
  #   Only include the visible address elements unless full_visibility == true
  def entire_address(full_visibility: false)
    address_arr = full_visibility ? address_array(self.class.max_visibility) : address_array
    address_arr.join(ADDR_JOINER)
  end


  def visibility_none?
    visibility == self.class.no_visibility
  end


  def visibility_max?
    visibility == self.class.max_visibility
  end


  # Geocode the address, starting with all of the data.
  #  If we don't get a geocoded result, then keep trying,
  #  using less and less 'specific' address information
  #  until we can get a latitude, longitude returned from geocoding.
  # This will handle addresses that aren't correct (ex: generated with FFaker or possibly entered wrong)
  # and so will guarantee that at least *some* map can be displayed.  (Important for a company!)
  def geocode_best_possible

    return unless addressable_type == 'Company'

    # don't Geocode if we're doing development or testing AND
    # we already have lat and long and nothing has changed
    return if dev_or_test_and_have_geo_unchanged?

    specificity_order = address_array

    most_specific = 0
    least_specific = specificity_order.size - 1

    geo_result = nil

    until most_specific > least_specific || geo_result.present?
      geocode_address = specificity_order[most_specific..least_specific].compact.join(', ')
      geo_result = Geocoder.search(geocode_address)
      most_specific += 1
    end

    unless geo_result.nil?
      self.latitude = geo_result[0].latitude
      self.longitude = geo_result[0].longitude
    end

  end


  # TODO: Make this a private method after a one-time rake task - which updates
  #       non-conforming city names in addresses - has been run.
  def format_city_name
    # Capitalize first letter of each word
    # Convert remaining letters of each word to lower case
    # Remove leading and trailing white space
    # Reduce internal string of multiple white spaces to single white space
    # Preserve non-whitespace, non-word characters as-is (e.g. dashes)

    self.city = city.strip.gsub(/\s\s+/, ' ').gsub(/(\w|å|ä|ö|Å|Ä|Ö)+/) do |word|
      word.mb_chars.capitalize.to_s
    end
  end


  private

  # Are we doing development or testing
  #  AND already  have the latitude and longitude
  #  AND it is  new AND one of the geolocation fields have NOT changed?
  def dev_or_test_and_have_geo_unchanged?
    (Rails.env.development? || Rails.env.test?) &&
      (!latitude.nil? && !longitude.nil?)  &&
      (self.new_record? || !((self.changed & GEO_FIELDS).any?) )
  end


  def sverige_if_nil
    country = 'Sverige' if country.nil?
    country
  end

end
