class AddMembershipExpiringSoonDaysToAppConfiguration < ActiveRecord::Migration[5.2]
  def change
    add_column :app_configurations, :membership_expiring_soon_days, :integer, default: 60, null: false, comment: "Number of days to start saying a membership is expiring soon"
  end
end
