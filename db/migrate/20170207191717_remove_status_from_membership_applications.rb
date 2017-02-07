class RemoveStatusFromMembershipApplications < ActiveRecord::Migration[5.0]
  def change
    remove_column :membership_applications, :status, :string
  end
end
