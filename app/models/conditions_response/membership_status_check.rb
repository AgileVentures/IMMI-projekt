# Revoke membership status if requirements are met

class MembershipStatusCheck < ConditionResponder

  def self.condition_response(condition, log, use_slack_notification: true)
    confirm_correct_timing(get_timing(condition), TIMING_EVERY_DAY, log)

    User.current_member.each do |user|
      MembershipStatusUpdater.instance.update_membership_status(user) unless user.admin?
    end
  end
end
