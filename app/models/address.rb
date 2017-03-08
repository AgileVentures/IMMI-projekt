class Address < ApplicationRecord

  belongs_to :addressable, polymorphic: true

  belongs_to :region

  belongs_to :kommun


  validates_presence_of :addressable

  validates_presence_of :country


  scope :has_region, -> { where('region_id IS NOT NULL') }

  scope :lacking_region, -> { where('region_id IS NULL') }


  geocoded_by :entire_address

  after_validation :geocode_best_possible,
                   :if => lambda { |obj| obj.changed? }


  def entire_address
    # Google can't handle 'Sveriges' as the country :-(
    [street_address, city, post_code, translate_sveriges_country].compact.join(', ')
  end


  # Geocode the address, starting with all of the data.
  #  If we don't get a geocoded result, then keep trying,
  #  using less and less 'specific' address information
  #  until we can get a latitude, longitude returned from geocoding.
  # This will handle addresses that aren't correct (ex: generated with FFaker or possibly entered wrong)
  # and so will guarantee that at least *some* map can be displayed.  (Important for a company!)
  def geocode_best_possible

    specificity_order = [street_address, post_code, city, translate_sveriges_country]

    most_specific = 0
    least_specific = specificity_order.size - 1

    geo_result = nil

    until most_specific > least_specific || !geo_result.nil?
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


  def translate_sveriges_country
    country = 'Sveriges' if country.nil?
    country.downcase == 'sveriges' ? 'Sweden' : country
  end

end