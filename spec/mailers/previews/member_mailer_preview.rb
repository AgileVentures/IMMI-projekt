# Preview all emails at http://localhost:3000/rails/mailers

require_relative 'pick_random_helpers'

class MemberMailerPreview < ActionMailer::Preview

  include PickRandomHelpers

  def membership_granted
    approved_app = ShfApplication.where(state: :accepted).first
    MemberMailer.membership_granted(approved_app.user)
  end

  def membership_will_expire
    member = User.where(member: true).first
    MemberMailer.membership_will_expire(member)
  end

end
