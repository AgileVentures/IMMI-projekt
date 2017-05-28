class MembershipApplicationPolicy < ApplicationPolicy


  def permitted_attributes
    allowed_attribs_for_current_user
  end


  def permitted_attributes_for_create
    allowed_attribs_for_current_user
  end


  def permitted_attributes_for_show
    user ? all_attributes : []
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
    is_admin?
  end


  def create?
    new?
  end


  def information?
    user
  end


  def accept?
    is_admin?
  end


  def reject?
    is_admin?
  end


  def need_info?
    is_admin?
  end


  def cancel_need_info?
    is_admin?
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
    owner_attributes + [:membership_number, :reason_waiting, :reason_waiting_custom_text]
  end


  def owner_attributes
    user_owner_attributes + [:state]
  end


  def allowed_attribs_for_current_user
    if user && user.admin?
      all_attributes
    elsif user && owner?
      owner_attributes
    else
      user_owner_attributes
    end
  end


  def owner?
    user && @record.respond_to?(:user) && @record.user == user
  end

end
