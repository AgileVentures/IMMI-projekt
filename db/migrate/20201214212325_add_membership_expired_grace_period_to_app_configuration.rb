class AddMembershipExpiredGracePeriodToAppConfiguration < ActiveRecord::Migration[5.2]
  def change
    add_column :app_configurations, :membership_expired_grace_period, :integer, default: 90, null: false, comment: "Number of days after membership expiration that a member can pay without penalty"
  end
end
