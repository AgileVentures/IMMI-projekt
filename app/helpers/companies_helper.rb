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

      company.addresses.visible.includes(:kommun).each do |address|
        results << {latitude: address.latitude,
                    longitude: address.longitude,
                    text: html_marker_text(company, address, name_html: name_html) }
      end
    end

    results
  end


  # html to display for a company when showing a marker on a map
  #  if no name_html is given (== nil), it will be linked to the company,
  #  else the name_html string will be used
  def html_marker_text company, address, name_html:  nil
    text = "<div class='map-marker'>"
    text <<  "<p class='name'>"
    text << (name_html.nil? ? link_to(company.name, company, target: '_blank') : name_html)
    text <<  "</p>"
    text << "<p class='categories'>#{list_categories company, ', '}</p>"
    text << "<br>"
    text << "<p class='entire-address'>#{address.entire_address}</p>"
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
end
