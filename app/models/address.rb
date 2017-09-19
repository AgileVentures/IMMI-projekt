class Address < ApplicationRecord

  belongs_to :addressable, polymorphic: true

  # When an address is initially created, it may not have a kommun or region assigned,
  # for example when an admin creates a company but doesn't have all of the info for the main address.
  belongs_to :region, optional: true

  belongs_to :kommun, optional: true

  validates_presence_of :addressable

  validates_presence_of :country

  ADDRESS_VISIBILITY = %w(street_address post_code city kommun none)

  validates :visibility, inclusion: ADDRESS_VISIBILITY

  scope :has_region, -> { where('region_id IS NOT NULL') }

  scope :lacking_region, -> { where('region_id IS NULL') }

  scope :visible, -> { where.not(visibility: 'none') }

  geocoded_by :entire_address

  after_validation :geocode_best_possible,
                   :if => lambda { |obj| obj.changed? }

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


  def address_array
    # This should only be called for an address associated with a company

    # Returns an array of address field values (strings) that starts with the
    # attribute associated with the  visibility level set for this address.

    address_pattern = %w(street_address post_code city kommun)

    pattern_length = address_pattern.length

    start_index = address_pattern.find_index do |field|
      field == visibility
    end

    return [] unless start_index

    if kommun
      ary = [street_address, post_code, city, kommun.name,
             sverige_if_nil][start_index..pattern_length]
    else
      ary = [street_address, post_code, city,
             sverige_if_nil][start_index..(pattern_length-1)]
    end
    ary.delete_if { |f| f.blank? }
  end


  def entire_address
    address_array.compact.join(', ')
  end


  # Geocode the address, starting with all of the data.
  #  If we don't get a geocoded result, then keep trying,
  #  using less and less 'specific' address information
  #  until we can get a latitude, longitude returned from geocoding.
  # This will handle addresses that aren't correct (ex: generated with FFaker or possibly entered wrong)
  # and so will guarantee that at least *some* map can be displayed.  (Important for a company!)
  def geocode_best_possible

    return unless addressable_type == 'Company'

    specificity_order = address_array

    most_specific = 0
    least_specific = specificity_order.size - 1

    geo_result = nil

    until most_specific > least_specific || geo_result.present?
      geocode_address = specificity_order[most_specific..least_specific].compact.join(', ')
      geo_result = Geocoder.coordinates(geocode_address)
      most_specific += 1
    end

    unless geo_result.nil?
      self.latitude = geo_result.first
      self.longitude = geo_result.last
    end

  end


  private


  def sverige_if_nil
    country = 'Sverige' if country.nil?
    country
  end

end
