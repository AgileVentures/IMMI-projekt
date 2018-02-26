class ShfApplicationPolicy < ApplicationPolicy

  EDITABLE_STATES_FOR_APPLICATION = Set[:new, :initial, :ready_for_review, :under_review, :waiting_for_applicant].freeze


  def permitted_attributes
    allowed_changeable_attribs_for_current_user
  end


  def permitted_attributes_for_new
    allowed_changeable_attribs_for_current_user
  end


  def permitted_attributes_for_create
    allowed_changeable_attribs_for_current_user
  end


  def permitted_attributes_for_show
     admin_or_owner? ? all_attributes : []
  end


  def permitted_attributes_for_edit
    allowed_changeable_attribs_for_current_user
  end


  def permitted_attributes_for_update
    allowed_changeable_attribs_for_current_user
  end


  def permitted_attributes_for_destroy
    if user && user.admin?
      all_attributes
    elsif owner?
      user_owner_attributes
    else
      []
    end
  end


  def index?
    user.admin?
  end


  # an Admin cannot create an Application because we currently have no way to say who the application is for (which User)
  def new?
    super && !user.admin? && not_a_visitor
  end


  def create?
    record.is_a?(ShfApplication) ? owner? : !user.admin? && not_a_visitor
  end


  def update?
    return true if user.admin?

    user == record.user && EDITABLE_STATES_FOR_APPLICATION.include?(record.state.to_sym)
  end


  def information?
    not_a_visitor
  end


  def accept?
    user.admin?
  end


  def reject?
    user.admin?
  end


  def need_info?
    user.admin?
  end


  def cancel_need_info?
    user.admin?
  end


  def start_review?
    user.admin?
  end


  #------
  private


  def user_owner_attributes
    [
        :company_number,
        :contact_email,
        :phone_number,
        { business_category_ids: [] },
        :marked_ready_for_review,
        :uploaded_files,
        uploaded_files_attributes: [:id,
                                    :actual_file,
                                    :actual_file_file_name,
                                    :actual_file_file_size,
                                    :actual_file_content_type,
                                    :actual_file_updated_at,
                                    :_destroy],
        user_attributes: [:first_name,
                          :last_name]
    ]
  end


  def all_attributes
    owner_attributes + [:membership_number, :waiting_reason, :custom_reason_text, :member_app_waiting_reasons_id]
  end


  def owner_attributes
    user_owner_attributes + [:state]
  end


  def allowed_changeable_attribs_for_current_user
    if user.admin?
      all_attributes
    elsif owner?
      application_is_approved_or_rejected? ? [] : owner_attributes
    elsif user_has_other_application?
      []
    elsif not_a_visitor
      user_owner_attributes
    else
      []
    end
  end


  def application_is_approved_or_rejected?
    [:accepted, :rejected].include?(record.state.to_sym)
  end

  def user_has_other_application?
    user.shf_application && user.shf_application != record
  end


  def owner?
    record.respond_to?(:user) && record.user == user
  end


  def not_a_visitor
    !user.is_a? Visitor
  end

end
