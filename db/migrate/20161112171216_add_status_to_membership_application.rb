class AddStatusToMembershipApplication < ActiveRecord::Migration[5.0]
  def change
    add_column :membership_applications, :status, :string, default: 'Pending'
  end
end
