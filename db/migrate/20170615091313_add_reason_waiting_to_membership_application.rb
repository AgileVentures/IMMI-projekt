class AddReasonWaitingToMembershipApplication < ActiveRecord::Migration[5.0]

  def change
    add_reference :membership_applications, :member_app_waiting_reasons, foreign_key: true
    add_column :membership_applications, :custom_reason_text, :string
  end

end
