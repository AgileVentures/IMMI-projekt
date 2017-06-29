class MembershipApplicationPolicy < ApplicationPolicy


  def permitted_attributes
    allowed_attribs_for_current_user
  end


  def permitted_attributes_for_create
    allowed_attribs_for_current_user
  end


  def permitted_attributes_for_show
    not_a_visitor ? all_attributes : []
  end


  def permitted_attributes_for_edit
    allowed_attribs_for_current_user
  end


  def permitted_attributes_for_update
    allowed_attribs_for_current_user
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


  def new?
    user.admin?
  end


  def create?
    new?
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


  #------
  private


  def user_owner_attributes
    [:first_name,
     :last_name,
     :company_number,
     :contact_email,
     :phone_number,
     {business_category_ids: []},
     :marked_ready_for_review,
     :uploaded_files,
     uploaded_files_attributes: [:id,
                                 :actual_file,
                                 :actual_file_file_name,
                                 :actual_file_file_size,
                                 :actual_file_content_type,
                                 :actual_file_updated_at,
                                 :_destroy]
    ]
  end


  def all_attributes
    owner_attributes + [:membership_number, :waiting_reason, :custom_reason_text, :member_app_waiting_reasons_id]
  end


  def owner_attributes
    user_owner_attributes + [:state]
  end


  def allowed_attribs_for_current_user
    if user.admin?
      all_attributes
    elsif owner?
      owner_attributes
    elsif not_a_visitor
      user_owner_attributes
    else
      []
    end
  end


  def owner?
    @record.respond_to?(:user) && @record.user == user
  end

  def not_a_visitor
    ! user.is_a? Visitor
  end

end
