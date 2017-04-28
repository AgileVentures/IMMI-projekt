module CompaniesHelper

  def last_category_name company
    company.business_categories.any? ? company.business_categories.last.name : ''
  end


  def list_categories company, separator=' '
    if company.business_categories.any?
      company.business_categories.order(:name).map(&:name).join(separator)
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
    Company::ADDRESS_VISIBILITY.map do |visibility_level|
      [ I18n.t("address_visibility.#{visibility_level}"), visibility_level ]
    end
  end

  # if user == company member || user == admin, show all fields
  # else show all fields consistent with address_visibility
  #  - return array of fields to be shown
  #  - return nil if no fields are to be shown
  # Array contains a hash - one for each field - with two keys:
  #  - name: name of field (Address) attribute
  #  - label: label of field (for I18n lookup)
  #  - method: name of value method to call on attribute (non-null for association)
  def show_address_fields(user, company)

    all_fields = [ { name: 'street_address', label: 'street', method: nil },
                   { name: 'post_code', label: 'post_code', method: nil },
                   { name: 'city', label: 'city', method: nil },
                   { name: 'kommun', label: 'kommun', method: 'name' },
                   { name: 'region', label: 'region', method: 'name' } ]

    if user&.admin? || user&.is_in_company_numbered?(company.company_number)
      all_fields
    else
      start_index = all_fields.find_index do |field|
        field[:name] == company.address_visibility
      end

      start_index ? all_fields[start_index, all_fields.length] : nil
    end
  end

end
