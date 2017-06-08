module AdminOnly
  
  class MemberAppWaitingReason < ApplicationRecord

    validates_presence_of :name_sv


    # Is this the placeholder for "Other (enter a custom reason)" for the UI (true) or a custom reason entered (false)
    def other_reason_placeholder?
      name_sv == self.class.other_reason_name
    end


    # This is effectively a CONSTANT that is used in the UI
    def self.other_reason_name
      I18n.t('admin_only.member_app_waiting_reasons.other_custom_reason')
    end


    def self.default_name_method
      :name_sv
    end

  end

end

