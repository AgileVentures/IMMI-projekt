require_relative('../seed_helpers.rb')
require_relative '../require_all_seeders_and_helpers'

module SeedHelper
  #--------------------------
  #
  # @class PredefinedUsersFactory
  #
  # @desc Responsibility: Create Users with specific attributes, etc.
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   12/10/20
  #
  # TODO: Use existing methods to create applications, etc.
  #--------------------------
  #
  class UsersFactory

    # Used to make a certain number of users with random applications, companies, etc.
    NUM_NEWUSERS = 3
    NUM_APPLICANTS = 4
    NUM_MEMBERS = 2
    NUM_LAPSEDMEMBERS = 3
    NUM_FORMERMEMBERS = 2

    NEWUSER_LNAME = 'NewUser'
    APPLICANT_LNAME = 'Applicant'
    MEMBER_LNAME = 'Member'
    LAPSEDMEMBER_LNAME = 'LapsedMember'
    FORMERMEMBER_LNAME = 'FormerMember'

    DUMMY_EMAIL_DOMAIN = 'example.com'

    # --------------------------------------------------------------------------------------------

    def self.seed_predefined_users
      make_predefined_new_registered_users
      make_predefined_applicants
      make_predefined_current_members
      make_predefined_lapsed_members
      make_predefined_former_members
    end

    # New users are those that have signed up, but not submitted any application or done anything else.
    #   (They have not agreed to any Ethical Guidelines, etc.)
    def self.make_predefined_new_registered_users
      make_predefined_with(lastname: NEWUSER_LNAME, number: NUM_NEWUSERS)
    end

    # Applicants have created a new application (but the application has not been reviewed).  Some
    #   percentage have done 'other' requirements. (As of 2020-12-10,there is only one 'other'
    #   requirement:  agree to the Ethical Guidelines.  But there could be additional requirements
    #   in the future.)
    # ShfApplications and Companies are created for the applicants
    def self.make_predefined_applicants
      make_predefined_with(lastname: APPLICANT_LNAME, number: NUM_APPLICANTS) do |applicant|
        make_n_save_app(applicant, MA_NEW_STATE)
      end
    end

    # Current members are those that have met all of the requirements for membership and have
    #   paid.  Some percentage have paid in advance (for more than 1 membership term).
    # ShfApplications and Companies are created for the members.
    def self.make_predefined_current_members
      make_member_paid_through(Date.current + 1.day, firstname: 'PaidThrough-tomorrow')
      make_member_paid_through(Date.current + 1.month, firstname: 'PaidThrough-1-month')

      # earliest_renew_days = User.days_can_renew_early
      # earliest_str = earliest_renew_days.inspect.gsub(' ', '_')
      # make_member_paid_through(Date.current + earliest_renew_days, firstname: "PaidThrough-#{earliest_str}")
      # make_member_paid_through(Date.current + earliest_renew_days + 1, firstname: "PaidThrough-#{earliest_str}_plus_1_day")
      # make_member_paid_through(Date.current + earliest_renew_days - 1, firstname: "PaidThrough-#{earliest_str}_minus_1_day")

      make_member_paid_through(Date.current + 6.months, firstname: 'PaidThrough-6-months')
      make_member_paid_through(Date.current + 2.years, firstname: 'PaidThrough-2-years')
    end

    # Lapsed members are those members that
    def self.make_predefined_lapsed_members

    end

    # Members with payments overdue are those whose last payment date has past
    #   AND are in the 'grace period' of when they can pay.
    # They may or may not have completed all of the requirements for renewing membership for the
    # membership term. Ex: If the requirement for renewing membership includes "must upload at least
    # 1 file" they may or may not have done that.  The requirements for renewing membership are
    # separate from payments.
    def self.make_predefined_members_payment_overdue

    end

    # Former members are those whose last payment date has past AND they are past the 'grace period'
    #   as well.
    def self.make_predefined_former_members

    end

    def self.make_member_paid_through(last_payment_expiry, lastname: MEMBER_LNAME, number: 1, firstname: 'PaidThrough')
      make_predefined_with(lastname: lastname, number: number, firstname: firstname) do |member|
        payment_ends_tomorrow = make_n_save_app(member, MA_ACCEPTED_STATE)
        membership_payment = payment_ends_tomorrow.most_recent_membership_payment
        membership_payment.update(expire_date: last_payment_expiry, start_date: User.start_date_for_expire_date(last_payment_expiry))
      end
    end

    def self.make_predefined_with(lastname: 'Someone', number: 1, firstname: nil)
      number.times do |i|
        user = new_user(lastname, number: i, firstname: firstname)
        yield(user) if block_given?
      end
    end

    # @return [User] - created with the given last name, and email and firstname based on the last name
    #   and number.
    def self.new_user(lastname = 'SomeUser', number: 1, firstname: nil)
      fname = firstname.blank? ? firstname_from_lastname_num(lastname, number) : firstname
      new_email = email_from_firstname(fname)

      raise "Could not create new user #{new_email}. That email is already taken." if User.all.pluck(:email).include?(new_email)

      User.create!(email: new_email,
                   password: DEFAULT_PASSWORD,
                   first_name: fname,
                   last_name: lastname)
    end

    def self.firstname_from_lastname_num(lastname, num = 1)
      "#{lastname}#{num}"
    end

    def self.email_from_firstname(firstname)
      "#{firstname.downcase}@#{DUMMY_EMAIL_DOMAIN}"
    end
  end

end
