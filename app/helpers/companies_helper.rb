module CompaniesHelper

  def payment_visible_for_user?(user, company)
    user.admin? || user.in_company_numbered?(company.company_number)
  end


  def list_categories(company, separator=' ', include_subcategories=false)
    company.categories_names(include_subcategories).join(separator)
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
    companies.flat_map do |company|
      name_html = link_name ?  nil : company.name

      company.addresses_visible.map do |address|
        { latitude: address.latitude,
          longitude: address.longitude,
          text: html_marker_text(company, address, name_html: name_html) }
      end
    end
  end


  # html to display for a company when showing a marker on a map
  #  if no name_html is given (== nil), it will be linked to the company,
  #  else the name_html string will be used
  def html_marker_text(company, address, name_html: nil)
    text = "<div class='map-marker'>"
    text << "<p class='name'>"
    text << (name_html.nil? ? link_to(company.name, company, target: '_blank') : name_html)
    text << "</p>"
    text << "<p class='categories'>#{list_categories(company, ', ')}</p>"
    text << "<p class='entire-address'>#{address.entire_address}</p>"
    text << "</div>"

    text
  end

  # Creates an array which contains an array of [text, value]
  #  for each company address_visibility level (for selection in form)
  def address_visibility_array
    Address.address_visibility_levels.map do |visibility_level|
      [ I18n.t("address_visibility.#{visibility_level}"), visibility_level ]
    end
  end


  def html_postal_format_entire_address(co, person_name: nil)
    lines = postal_format_entire_address(co, person_name: person_name)
    tag.div class: 'postal-address' do
      lines.map{|line| concat tag.p line}.join(' ')
    end
  end


  # Return the entire address in the postal mailing format for Sweden
  # Ignore address visibility settings (TODO: is this what we want? should this method be authorized)
  def postal_format_entire_address(co, person_name: nil)
    first_lines = person_name.nil? ? [co.name] : [co.name, person_name.to_s]

    address_lines = []
    # address_items = co.main_address.address_array(Address.max_visibility)
    address = co.main_address
    address_lines << address.street_address
    address_lines << "#{address.post_code} #{address.city}"

    first_lines + address_lines
  end


  def company_number_selection_field(company_id=nil)
    select_tag :company_id,
       options_from_collection_for_select(Company.order(:company_number),
                  :id, :company_number, company_id),
       class: 'search_field',
       data: {language: "#{@locale}" }
  end

  def company_number_entry_field(company_numbers)
    text_field_tag :company_number, company_numbers,
                     id: 'shf_application_company_number',
                     class: 'form-control'
  end

  def short_h_brand_url(company)
    url = company_h_brand_url(company)
    company.get_short_h_brand_url(url)
  end
end
