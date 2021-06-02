#--------------------------
#
# @class Memberships::NewIndividualMembershipActions
#
# @desc Responsibility: Do all the things that need to be done when a new individual membership is created.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   3/7/21
#
# TODO: what if they are a current_member and the last day > the date?
#   end the current membership on (date - 1 day) and start the new one on the date?
#
#--------------------------------------------------------------------------------------------------
module Memberships
  class NewIndividualMembershipActions < MembershipActions

    LOGMSG_MEMBERSHIP_GRANTED = 'New membership granted'


    def self.other_keyword_args_valid?(other_keyword_args)
      !!other_keyword_args.fetch(:first_day, false)
    end

    # Create a new membership with the first day as the given first_day
    # Set the membership number for the user
    # If we should send email:
    #   send email to the user saying their membership is granted
    #   send email to the admin if this is the first membership AND the user has a company in good standing
    #
    def self.accomplish_actions(user, send_email: SEND_EMAIL_DEFAULT, **other_keyword_args)
      first_day = other_keyword_args[:first_day]

      # create a new Membership for the user
      last_day = Membership.last_day_from_first(first_day)
      user.memberships << Membership.create!(user: user, first_day: first_day, last_day: last_day)

      # set the membership number for the user
      user.update!(member: true, membership_number: user.issue_membership_number) # FIXME User should not be responsible for the new membership number

      AdminAlerter.instance.new_membership_granted(user, deliver_email: send_email)
      MemberMailer.membership_granted(user).deliver if send_email

      true # success!
    end


    def self.log_message_success
      LOGMSG_MEMBERSHIP_GRANTED
    end
  end

end
