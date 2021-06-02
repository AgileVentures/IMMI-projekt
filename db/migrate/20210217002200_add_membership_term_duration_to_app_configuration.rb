class AddMembershipTermDurationToAppConfiguration < ActiveRecord::Migration[5.2]
  def change
    add_column :app_configurations, :membership_term_duration, :string, default: 'P1Y', null: false, comment: "ISO 8601 Duration string format. Must be used so we can handle leap years. default = 1 year"
  end
end
