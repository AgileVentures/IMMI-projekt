class AddReasonWaitingToMembershipApplication < ActiveRecord::Migration[5.0]

  def change
    add_column :membership_applications, :reason_waiting, :string
  end

end
