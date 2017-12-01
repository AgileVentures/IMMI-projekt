module ApplicationHelper

  def beta_user?(user)
    return true unless ENV['SHF_BETA'] == 'yes'

    BETA_USERS.include?(user.email)
  end

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


  # call field_or_default with the default value = an empty String
  def field_or_none(label, value, tag: :p, tag_options: {}, separator: ': ',
                    label_class: 'field-label', value_class: 'field-value')

    field_or_default(label, value, default: '', tag: tag, tag_options: tag_options, separator: separator,
                     label_class: label_class, value_class: value_class)
  end


  # Return the HTML for a simple field with "Label: Value"
  # If value is blank, return the value of default (default value for default = '')
  # Surround it with the given content tag (default = :p if none provided)
  # and use the tag options (if any provided).
  # Default class to surround the label and separator is 'field-label'
  # Default class to surround the value is 'field-value'
  #
  # Separate the Label and Value with the separator string (default = ': ')
  #
  #  Ex:  field_or_none('Name', 'Bob Ross')
  #     will produce:  "<p><span class='field-label'>Name: </span><span class='field-value'>Bob Ross</span></p>"
  #
  #  Ex:  field_or_default('Name', '', default: '(no name provided)')
  #     will produce:  "(no name provided)"
  #
  #  Ex:  field_or_default('Name', '', default: content_tag( :h4, '(no name provided)', class: 'empty-warning') )
  #     will produce:  "<h4 class='empty-warning'>(no name provided)</h4>"
  #
  # Ex: field_or_none('Name', 'Bob Ross', tag: :h2, separator: ' = ')
  #     will produce:  "<h2><span class='field-label'>Name = </span><span class='field-value'>Bob Ross</span></h2>"
  #
  # Ex: field_or_none('Name', 'Bob Ross', tag_options: {id: 'bob-ross'}, value_class: 'special-value')
  #     will produce:  "<p id='bob-ross'><span class='field-label'>Name: </span><span class='special-value'>Bob Ross</span></p>"
  #
  def field_or_default(label, value, default: '', tag: :p, tag_options: {}, separator: ': ',
                       label_class: 'field-label', value_class: 'field-value')


    if value.blank?
      default
    else
      content_tag(tag, tag_options) do
        concat content_tag(:span, "#{label}#{separator}", class: label_class)
        concat content_tag(:span, value, class: value_class)
      end
    end

  end



  # Construct a string that can be used by CSS to style things in a particular view.
  def item_view_class(active_record_item, action_name)
    "#{action_name} #{active_record_item.class.name.downcase} #{unique_css_id(active_record_item)}"
  end


  # Construct a CSS identifier unique to this instance of an ActiveRecord
  # This is helpful so that this item can be uniquely identified on a page
  #  so that it can be (perhaps uniquely) styled.
  #
  # If the item does not have an ID, then we will have to assign on based on the
  # current UTC time in seconds, which will be of little use for CSS styling, but
  # there are no pretty alternatives.
  def unique_css_id(active_record_item)

    unique_id = if active_record_item.respond_to?(:id) && active_record_item.id
                  active_record_item.id.to_s
                else
                  "no-id--#{Time.now.utc.to_i}"
                end

    "#{active_record_item.class.name.downcase}-#{unique_id}"
  end

  # Returns a string of option tags for a 'select' element.
  # The select element allows the user to select the number of items to
  # appear on each pagination page.
  # The 'count' argument is the currently-select items count.

  ITEMS_COUNT = [ ['10', 10], ['25', 25], ['50', 50], ['All', 'All'] ].freeze

  def paginate_count_options(count=10)
    options_for_select(ITEMS_COUNT, count)
  end

  def model_errors_helper(model_instance)
    html = ''
    errs = model_instance.errors.count

    if errs > 0
      html = content_tag(:div, "#{t('model_errors', count: errs)}:",
                         class: 'wpcf7-response-output standard-label')

      model_instance.errors.full_messages.each do |msg|
        html << content_tag(:div, msg, class: 'wpcf7-response-output')
      end
    end

    html.empty? ? nil : html + tag(:br)
  end

  def boolean_radio_buttons_collection(text_vals = { true: 'Yes', false: 'No' })
    # Returns generic collection for radio buttons for a boolean field,
    # suitable for use in radio button selection fields.  Text values are
    # translated. Can pass in preferred strings for "true" and "false" text values.
    [ [true, t(text_vals[:true])], [false, t(text_vals[:false])] ]
  end

  def expire_date_label_and_value(entity)
    if entity.is_a? User
      expire_date = entity.membership_expire_date
    else
      expire_date = entity.branding_expire_date # Company
    end

    if !expire_date
      return field_or_none("#{t('activerecord.attributes.payment.expire_date')}",
                           "#{t('none')}", label_class: 'standard-label')
    end

    # Show expire date as yellow if within 1 month from today, red if expired
    value_class = expire_date_css_class(expire_date)

    return field_or_none("#{t('activerecord.attributes.payment.expire_date')}",
                         "#{expire_date}",
                         label_class: 'standard-label',
                         value_class: value_class)
  end

  def expire_date_css_class(expire_date)
    today = Time.zone.today
    if today < expire_date.months_ago(1)  # expire_date minus one month
      value_class = 'Yes'  # green
    elsif today >= expire_date
      value_class = 'No'
    else
      value_class = 'Maybe'
    end
    value_class
  end

  def payment_notes_label_and_value(entity)
    if entity.is_a? User
      notes = entity.membership_payment_notes
    else
      notes = entity.branding_payment_notes
    end

    if !notes || notes.empty?
      return field_or_none("#{t('activerecord.attributes.payment.notes')}",
                           "#{t('none')}", label_class: 'standard-label')
    end
    return field_or_none("#{t('activerecord.attributes.payment.notes')}",
                         notes, label_class: 'standard-label')
  end

end
