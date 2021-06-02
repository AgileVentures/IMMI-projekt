class AddMembershipStatusToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :membership_status, :string
    add_index :users, :membership_status
  end
end
