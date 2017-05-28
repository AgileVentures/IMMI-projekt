module MembershipApplicationsHelper

  def can_edit_state?
    policy(@membership_application).permitted_attributes_for_edit.include? :state
  end

  def member_full_name
    @membership_application ? "#{@membership_application.first_name} #{@membership_application.last_name}" : '..'

  end


  # For now, we are assuming this list won't change a whole lot or be large.
  #  So we'll just get the few itmes from the locale file. If this assumption
  #  proves to be wrong, the data for the list can be moved to the db (and then get the actual translations
  # either from the locale files or store the translations in the db somehow.)
  def reasons_for_waiting
      t('membership_applications.need_info.reason').invert.to_a
  end
  
end
