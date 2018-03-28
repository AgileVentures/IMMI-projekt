module CompaniesHelper

  def payment_visible_for_user?(user, company)
    user.in_company_numbered?(company.company_number) || user.admin?
  end

  def list_categories company, separator=' '
    company.categories_names.join(separator)
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

      company.addresses.map do |address|
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
    text << "<p class='categories'>#{list_categories company, ', '}</p>"
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

  def pay_branding_fee_link(company_id, user_id)
    # Returns link styled as a button

    link_to("#{t('menus.nav.company.pay_branding_fee')}",
            payments_path(user_id: user_id,
                          company_id: company_id,
                          type: Payment::PAYMENT_TYPE_BRANDING),
            { method: :post, class: 'btn btn-primary btn-xs' })
  end

  def company_number_selection_field(company_id=nil)
    select_tag :company_id,
       options_from_collection_for_select(Company.order(:company_number),
                  :id, :company_number, company_id),
       class: 'search_field',
       data: {language: "#{@locale}" }
  end

  def company_number_entry_field(company_number=nil)
    number_field_tag :company_number, company_number,
                     id: 'shf_application_company_number'
  end
end
