# Can take an address and generate a comman separated value (CSV) string
# (The string can be used to export information from SHF-project and then use it in other systems)
#
# The Swedish postal service expects that if the country is Sverige,
#  it appears on an envelope as 'Sweden-SE'
#
# If an address is nil, this can still generate an 'empty' string with the
# correct number of commas.
#

class AddressExporter

  SVERIGE_COUNTRY    = 'Sverige'
  SVERIGE_POSTAL_STR = 'SE-Sweden'



  def self.se_mailing_csv_str(address)

    num_items = 6

    if address
      kommun_str = address.kommun.nil? ? '' : address.kommun.name
      region_str = address.region.nil? ? '' : address.region.name

      str = '"' + (address.street_address.nil? ? '' : address.street_address )+ '",'

      str << "'#{address.post_code},#{address.city},#{kommun_str},#{region_str},#{self.country_postal(address)}"
      str
    else
      Array.new(num_items, '').join(',')
    end

  end



  # if country == 'Sverige' return what the Swedish Postal service wants to see for a mailing address
  def self.country_postal(address)

    if address
      address.country == SVERIGE_COUNTRY ? SVERIGE_POSTAL_STR : address.country
    else
      ''
    end

  end


end
