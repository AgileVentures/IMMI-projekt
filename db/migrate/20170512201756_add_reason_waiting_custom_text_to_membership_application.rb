class AddReasonWaitingCustomTextToMembershipApplication < ActiveRecord::Migration[5.0]

  def change
    add_column :membership_applications, :reason_waiting_custom_text, :string
  end

end
