#--------------------------
#
# @class  RequirementsForMemberUnpaidMoreThanXMonths
#
# @desc Responsibility:  Sends an email alert if a Member is > 6 months past the date they should have paid
#
#  Only 1 is needed for the system.
#
# @author Ashley Engelund ( weedySeaDragon @ Github )
# @date 2019-04-12
# @file member_unpaid_over6_months_alert.rb
#
#--------------------------


class MemberUnpaidOver6MonthsAlert < AdminEmailAlert


  NUM_MONTHS = 6

  # add the entity iff it is a member unpaid for 6 months
  def add_item_to_list?(user)
    RequirementsForMemberUnpaidMoreThanXMonths.requirements_met?({ user: user, num_months: NUM_MONTHS })
  end


  # Only send to the membership email.  Make a temporary admin user for this (not saved to the db)
  def recipients
    temp_admin_membership = User.new(first_name: 'Membership', last_name: 'Administrator',
                                     password: ENV['SHF_ADMIN_PWD'],
                                     email: ENV['SHF_MEMBERSHIP_EMAIL'])
    [ temp_admin_membership ]
  end


  def mailer_method
    :member_unpaid_over_x_months
  end


  def mailer_args(admin)
    [admin, items_list, NUM_MONTHS]
  end

end
