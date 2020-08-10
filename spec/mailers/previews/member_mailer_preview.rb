# Preview all emails at http://localhost:3000/rails/mailers

require_relative 'pick_random_helpers'


class MemberMailerPreview < ActionMailer::Preview

  include PickRandomHelpers


  def membership_granted
    approved_app = ShfApplication.where(state: :accepted).first
    check_co_name(approved_app.companies.first)
    MemberMailer.membership_granted(approved_app.user)
  end


  def membership_expiration_reminder
    member = User.where(member: true).first
    MemberMailer.membership_expiration_reminder(member)
  end


  def h_branding_fee_will_expire
    licensed_co = Company.branding_licensed.first
    co_member = licensed_co.users.last
    check_co_name(licensed_co)
    MemberMailer.h_branding_fee_will_expire(licensed_co, co_member)
  end


  # Previewing can cause this to be called twice:  once to create the header,
  # and again for the mail body.
  # So if the user already exists, use it, else create a new one
  def h_branding_fee_past_due

    new_email = unique_email

    unless (new_approved_user = User.find_by(email: new_email))
      new_approved_user = FactoryBot.create(:member_with_membership_app, email: new_email)
    end
    new_co = new_approved_user.shf_application.companies.first
    check_co_name(new_co)
    MemberMailer.h_branding_fee_past_due(new_co, new_approved_user)
  end


  def membership_lapsed

    lapsed_members = User.joins(:payments).where("payments.status = '#{Payment::SUCCESSFUL}' AND " +
                                                     "payments.payment_type = ? AND " +
                                                     " payments.expire_date < ?", Payment::PAYMENT_TYPE_MEMBER, Date.current)
        .joins(:shf_application).where(shf_applications: { state: 'accepted' })

    lapsed_member = if lapsed_members.size > 0
      lapsed_members.last
    else
      # take a current member and make their term expired!
      current = User.current_members
      if current.size > 0
        member = current.last
        most_recent_payment = member.most_recent_membership_payment
        most_recent_payment.update(expire_date: Date.current - 3)
        member
      else
        # Uh oh.  you have NO current members in the db.  You need to put some there so you can preview emails.
        #  This will throw an error but it's not important enough to spend development time on.
      end
    end

    MemberMailer.membership_lapsed(lapsed_member)
  end


  def company_info_incomplete

    approved_app = ShfApplication.where(state: :accepted).first
    approved_user = approved_app.user
    incomplete_co = approved_app.companies.first
    incomplete_co.update(name: '')
    incomplete_co.addresses.first.update(region: nil)
    check_co_name(incomplete_co)

    MemberMailer.company_info_incomplete(incomplete_co, approved_user)
  end


  def app_no_uploaded_files

    # create a new user with a brand new application (that has no uploaded files)
    new_email = "sussh-#{DateTime.now.strftime('%Q')}@example.com"

    new_approved_user = User.create(first_name: 'Suss',
                                    last_name: 'Hundapor',
                                    password: 'whatever',
                                    email: new_email,
                                    member_photo: nil,
    )
    ShfApplication.new(user: new_approved_user)

    MemberMailer.app_no_uploaded_files new_approved_user

  ensure
    User.delete(new_approved_user.id) unless new_approved_user.nil?
  end


  def first_membership_fee_owed
    # Create a new user with an approved application but no payments

    new_email = unique_email

    unless (new_approved_user = User.find_by(email: new_email))
      new_approved_user = FactoryBot.create(:user_with_membership_app, email: new_email, password: 'whatever')
    end
    shf_app = new_approved_user.shf_application
    shf_app.update(when_approved: Time.zone.now)
    shf_app.update(state: 'accepted')

    MemberMailer.first_membership_fee_owed(new_approved_user)
  end


private


  # create a unique email address based on the Time right now
  def unique_email
    "user-#{Time.now.to_i}@example.com"
  end


  # Sometimes if company is created for the preview, there is no name.
  # Check this and if the company name is blank, put one it.
  def check_co_name(company)
    company.update(name: 'Some Company AB') if company.name.blank?
  end

end
