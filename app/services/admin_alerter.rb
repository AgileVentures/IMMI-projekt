#--------------------------
#
# @class AdminAlerter
#
# @desc Responsibility: Send alerts to the admin
#
#    This is a Singleton.  Only 1 is needed for the system.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   4/3/21
#
#--------------------------

class AdminAlerter
  include Singleton

  SEND_EMAIL_DEFAULT = true

  # ------------------------------------------------------------------------------------------

  def send_email=(boolean_value = true)
    @send_email = boolean_value
  end


  def send_email
    @send_email ||= SEND_EMAIL_DEFAULT
  end


  def new_membership_granted(new_member, deliver_email: send_email)
    alert_admin_if_first_membership_with_good_co(new_member, deliver_email: deliver_email)
  end


  def payment_made(payment, deliver_email: send_email)
    alert_admin_if_first_membership_with_good_co(payment.user, deliver_email: deliver_email) #if payment.branding_license_payment?
  end


  # If this is the first membership for the user
  #   AND the membership belongs to at least one company in good standing (complete & licensed)
  # then email the Admin about it (so the Admin can, for example, send out a welcome message
  #   in social media: "Welcome NewMember who works for Company Z!")
  def alert_admin_if_first_membership_with_good_co(member, deliver_email: self.send_email )
    return unless deliver_email

    AdminMailer.new_membership_granted_co_hbrand_paid(member).deliver if member.current_member? &&
      member.memberships.size == 1 &&
      member.has_company_in_good_standing?
  end
end
