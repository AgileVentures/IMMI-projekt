class AddStateToMembershipApplications < ActiveRecord::Migration
  def change
    add_column :membership_applications, :state, :string, default: 'new'
  end
end
