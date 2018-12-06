class MembershipExpireAlert

  def self.condition_response(condition, log)

    return unless condition.name == 'membership_will_expire'

    send_membership_expiration_reminder(condition.config, log)
  end

  def self.send_membership_expiration_reminder(config, log)

    User.all.each do |user|
      if user.membership_current?
        days_until = (user.membership_expire_date - Date.current).to_i

        if config[:days].include?(days_until)

          MemberMailer.membership_expiration_reminder(user)
          log.record('info', "Expire alert sent to #{user.email}")
        end
      end
    end
  end
end
