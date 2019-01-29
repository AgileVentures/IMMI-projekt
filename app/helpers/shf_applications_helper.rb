module ShfApplicationsHelper

  def can_edit_state?
    policy(@shf_application).permitted_attributes_for_edit.include? :state
  end


  # The AASM gem caches the display_name for a State.  We cannot do that because
  # the I18n.locale may have changed, so we must get the localized name every time
  def states_selection_list
    ShfApplication.aasm.states.map { |state| [state.localized_name, state.name.to_s] }
  end


  def reasons_collection(other_reason_value, other_reason_text)
    collection = AdminOnly::MemberAppWaitingReason.all.to_a
    collection << AdminOnly::MemberAppWaitingReason.new(id: other_reason_value, "name_#{I18n.locale}" => "#{other_reason_text}")
    collection
  end


  def selected_reason_value(member_app, other_reason_value)
    (!member_app.custom_reason_text.blank?) ? other_reason_value : member_app.member_app_waiting_reasons_id
  end


  # the method to use to get the name for a reason, given the locale
  # If no locale is given, the current locale is used.
  # If the locale given isn't found or defined, the default name method is used
  def reason_name_method(locale = I18n.locale)
    reason_method 'name', locale
  end


  # the method to use to get the description for a reason, given the locale
  # If no locale is given, the current locale is used.
  # If the locale given isn't found or defined, the default name method is used
  def reason_desc_method(locale = I18n.locale)
    reason_method 'description', locale
  end


  # a collection of arrays with [the name of the reasons for waiting, the reason (object)]
  # in the locale
  def reasons_for_waiting_names(use_locale = I18n.locale)
    reasons_for_waiting_info('name', use_locale)
  end


  # a collection of arrays with [the descriptions of the reasons for waiting,  the reason (object)]
  # in the locale
  def reasons_for_waiting_descs(use_locale = I18n.locale)
    reasons_for_waiting_info('description', use_locale)
  end


  def list_app_categories application, separator=', '
    if application&.business_categories.any?
      application.business_categories.includes(:shf_applications)
        .map(&:name).sort.join(separator)
    end
  end


  private

  def reason_method(method_prefix, locale)
    possible_method = "#{method_prefix}_#{locale}".to_sym
    (AdminOnly::MemberAppWaitingReason.new.respond_to?(possible_method) ? possible_method : AdminOnly::MemberAppWaitingReason.send("default_#{method_prefix}_method".to_sym))
  end


  def reasons_for_waiting_info(method_prefix, locale)
    method_name = reason_method(method_prefix, locale)
    AdminOnly::MemberAppWaitingReason.all.map { |r| [r.id, r.send(method_name)] }
  end

  def file_delivery_radio_buttons_collection(locale = I18n.locale)
    collection = []

    text_method = "description_#{locale}".to_sym

    # Default option will be the first (left-most) button in the set
    AdminOnly::FileDeliveryMethod.order('default_option DESC').each do |delivery_method|
      collection << [ delivery_method.id, delivery_method.send(text_method) ]
    end

    collection
  end

end
