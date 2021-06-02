#--------------------------
#
# @class Memberships::RenewIndividualMembershipActions
#
# @desc Responsibility: Do all the things that need to be done when an individual membership is renewed.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   3/7/21
#
# TODO: what if they are a current_member and the last day > the date?
#   end the current membership on (date - 1 day) and start the new one on the date?
#--------------------------------------------------------------------------------------------------
module Memberships
  class RenewIndividualMembershipActions < MembershipActions

    LOGMSG_MEMBERSHIP_RENEWED = 'Membership renewed'


    def self.other_keyword_args_valid?(other_keyword_args)
      !!other_keyword_args.fetch(:first_day, false)
    end

    # Create a new membership with the first day as the given first_day
    # Set the membership number for the user
    # If we should send email:
    #   send email to the user saying their membership is renewed
    #
    def self.accomplish_actions(user, send_email: SEND_EMAIL_DEFAULT, **other_keyword_args)
      first_day = other_keyword_args[:first_day]

      # create a Membership for the user
      last_day = Membership.last_day_from_first(first_day)
      Membership.create!(user: user, first_day: first_day, last_day: last_day)
      user.update!(member: true)
      MemberMailer.membership_renewed(user).deliver if send_email

      true
    end


    def self.log_message_success
      LOGMSG_MEMBERSHIP_RENEWED
    end
  end

end
