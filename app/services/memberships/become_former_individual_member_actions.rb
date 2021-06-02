#--------------------------
#
# @class Memberships::BecomeFormerIndividualMemberActions
#
# @desc Responsibility: Do all the things that need to be done when an individual membership
#   enters the renewal grace period
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   4/1/21
#
#--------------------------------------------------------------------------------------------------
module Memberships
  class BecomeFormerIndividualMemberActions < MembershipActions

    LOGMSG_MEMBERSHIP_FORMER = 'Membership now a former membership'


    def self.other_keyword_args_valid?(_other_keyword_args)
      true
    end

    # Set membership to false
    # If we should send email:
    #   send email to the user saying they are now a former member and have to re-apply
    #
    def self.accomplish_actions(user, _send_email: SEND_EMAIL_DEFAULT, **other_keyword_args)
      user.update!(member: false)
      # MemberMailer.membership_now_is_former(user).deliver if send_email

      true
    end


    def self.log_message_success
      LOGMSG_MEMBERSHIP_FORMER
    end
  end

end
