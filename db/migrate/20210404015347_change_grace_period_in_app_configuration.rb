class ChangeGracePeriodInAppConfiguration < ActiveRecord::Migration[5.2]

  def up
    rename_column :app_configurations, :membership_expired_grace_period, :membership_expired_grace_period_duration
    change_column :app_configurations, :membership_expired_grace_period_duration, :string, default: 'P2Y', null: false, comment: "Duration of time after membership expiration that a member can pay without penalty. ISO 8601 Duration string format. Must be used so we can handle leap years."
    execute "UPDATE app_configurations SET membership_expired_grace_period_duration = 'P2Y';"
  end

  def down
    rename_column :app_configurations, :membership_expired_grace_period_duration, :membership_expired_grace_period

    # Change the column value to something that can be automatically converted to an integer before changing the type to integer
    execute "UPDATE app_configurations SET membership_expired_grace_period = '730';"

    # Have to drop the column default before changing the column type otherwise Postgres complains that it cannot convert it to an integer
    change_column_default :app_configurations, :membership_expired_grace_period, nil # effectively drops the default

    change_column :app_configurations, :membership_expired_grace_period, :integer, using: 'membership_expired_grace_period::integer', comment: "Number of days after membership expiration that a member can pay without penalty."
    change_column_default :app_configurations, :membership_expired_grace_period, 730
  end
end
