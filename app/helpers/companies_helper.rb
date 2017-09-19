module CompaniesHelper

  def list_categories company, separator=' '
    if company.business_categories.any?
      company.business_categories.includes(:membership_applications).map(&:name).sort.join(separator)
    end
  end


  # return a nicely formed URI for the company website
  # if the company website starts with with https://, return that.
  #  else ensure it starts with 'http://'
  def full_uri company
    uri = company.website
    uri =~ %r(https?://) ? uri : "http://#{uri}"
  end


  # Given a collection of companies, create an array of {latitude, longitude, marker}
  # for each company.  (Can be used by javascript to display markers for many companies)
  # if link_name is true (the default), the name of each company should be a link to its page
  #  else the name of each company should just be the name with no link to it
  def location_and_markers_for(companies, link_name: true)

    results = []

    companies.each do |company|
      link_name ? name_html = nil : name_html = company.name
      results << {latitude: company.main_address.latitude,
                  longitude: company.main_address.longitude,
                  text: html_marker_text(company, name_html: name_html) }
    end

    results
  end


  # html to display for a company when showing a marker on a map
  #  if no name_html is given (== nil), it will be linked to the company,
  #  else the name_html string will be used
  def html_marker_text company, name_html:  nil
    text = "<div class='map-marker'>"
    text <<  "<p class='name'>"
    text << (name_html.nil? ? link_to(company.name, company, target: '_blank') : name_html)
    text <<  "</p>"
    text << "<p class='categories'>#{list_categories company, ', '}</p>"
    text << "<br>"
    company.addresses.each do |addr|
      text << "<p class='entire-address'>#{addr.entire_address}</p>"
    end

    text << "</div>"

    text
  end

  # Creates an array which contains an array of [text, value]
  #  for each company address_visibility level (for selection in form)
  def address_visibility_array
    Address::ADDRESS_VISIBILITY.map do |visibility_level|
      [ I18n.t("address_visibility.#{visibility_level}"), visibility_level ]
    end
  end

  # `show_address_fields` returns an array used in company show view to
  # loop through and display all address fields for a company address,
  # consistent with:
  #  1) type of user, and,
  #  2) `visibility` set for the address
  #
  # If user == company member || user == admin, show all fields
  # else show all fields consistent with address visibility.
  # Two return values:
  #  Return value one:
  #    - array of fields to be shown
  #      - Array contains a hash - one for each field - with three keys:
  #        - name: name of field (Address) attribute
  #        - label: label of field (for I18n lookup)
  #        - method: name of value method to call on attribute (non-nil for association)
  #    - nil if no fields are to be shown
  #  Return value two:
  #    - true if address visibility value is to be shown
  #    - false otherwise
  def show_address_fields(user, address)

    all_fields = [ { name: 'street_address', label: 'street', method: nil },
                   { name: 'post_code', label: 'post_code', method: nil },
                   { name: 'city', label: 'city', method: nil },
                   { name: 'kommun', label: 'kommun', method: 'name' },
                   { name: 'region', label: 'region', method: 'name' } ]

    if user.admin? || user.is_in_company_numbered?(address.addressable.company_number)
      return all_fields, true
    else
      start_index = all_fields.find_index do |field|
        field[:name] == address.visibility
      end

      if start_index
        return all_fields[start_index..4], false
      else
        return nil, false
      end
    end
  end

end
