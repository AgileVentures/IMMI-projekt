# Preview all emails at http://localhost:3000/rails/mailers/membership_application_mailer


class MembershipApplicationMailerPreview < ActionMailer::Preview

  include PickRandomHelpers

  def accepted
    MembershipApplicationMailer.accepted(random_member_app(:accepted))
  end


  def acknowledge_received
    MembershipApplicationMailer.acknowledge_received(random_member_app)
  end


end
