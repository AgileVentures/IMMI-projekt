class AddIndexToMembershipApplication < ActiveRecord::Migration[5.0]
  def change
    add_index :membership_applications, :state
  end
end
