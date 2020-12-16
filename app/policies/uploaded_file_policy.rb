class UploadedFilePolicy < ApplicationPolicy

  def index?
    can_see_page_for_the_user?
  end

  def new?
    can_see_page_for_the_user?
  end

  def create?
    new?
  end

  # admin or owner can update if:
  #   - the uploaded file is associated with an ShfApplication AND the uploaded files can be editted or deleted
  #     OR
  #   - the uploaded file is not associated with an ShfApplication
  def update?
    admin_or_owner? && (record.shf_application.present? ? record.shf_application.can_edit_delete_uploads? : true)
  end

  def destroy?
    update?
  end

  private

  def can_see_page_for_the_user?
    user.admin? || (not_a_visitor? && user == record)
  end

end
