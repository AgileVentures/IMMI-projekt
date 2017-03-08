module ApplicationHelper
  def flash_class(level)
    case level.to_sym
      when :notice then
        'success'
      when :alert then
        'danger'
    end
  end


  def flash_message(type, text)
    flash[type] ||= []
    if flash[type].instance_of? String
      flash[type] = [flash[type]]
    end
    flash[type] << text
  end


  def render_flash_message(flash_value)
    if flash_value.instance_of? String
      flash_value
    else
      safe_join(flash_value, '<br/>'.html_safe)
    end
  end


  def translate_and_join(error_list)
    error_list.map { |e| I18n.t(e) }.join(', ')
  end


  # ActiveRecord::Assocations::CollectionAssociation is a proxy and won't
  # always load info. see the class documentation for more info
  def assocation_empty?(assoc)
    assoc.reload unless assoc.nil? || assoc.loaded?
    assoc.nil? ? true : assoc.size == 0
  end


  def i18n_time_ago_in_words(past_time)
    "#{t('time_ago', amount_of_time: time_ago_in_words(past_time))}"
  end


  def google_static_map(location, width: 300, height: 600, zoom: 11, marked: true)
    marker_info = marked ? "&markers=#{location.latitude}, #{location.longitude}" : ''
    "https://maps.googleapis.com/maps/api/staticmap?center=#{lat_long(location)}&size=#{width}x#{height}&zoom=#{zoom}#{marker_info}"
  end


  def google_maps_js_api
    "https://maps.googleapis.com/maps/api/js"
  end


  def google_key
    "#{Geocoder.config[:api_key]}"
  end


  def address_as_esc_html(location)
    location.entire_address.gsub(/[\s]/, '+')
  end


  def lat_long_as_esc_html(location)
    "#{location.latitude}%2C%20#{location.longitude}"
  end


  def google_location_part(location)
    "&location=#{lat_long(location)}"
  end


  def lat_long(location)
    "#{location.latitude},#{location.longitude}"
  end


  # show a simple field with Label: Value ,  surrounded by <p> with the styles
  #  if Value is blank, return an empty string

  def field_or_none(label, value, tag_options: {}, separator: ': ')

    if value.blank?
      ''
    else
      content_tag(:p, tag_options) do
        concat content_tag(:span, "#{label}#{separator}", class: 'field-label')
        concat content_tag(:span, value, class: 'field-value')
      end
    end

  end


end
