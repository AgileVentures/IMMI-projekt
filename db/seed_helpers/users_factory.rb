require_relative('../seed_helpers.rb')
require_relative '../require_all_seeders_and_helpers'

module SeedHelper
  #--------------------------
  #
  # @class UsersFactory
  #
  # @desc Responsibility: Create Users with specific attributes, etc.
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   12/10/20
  #
  #--------------------------
  #
  class UsersFactory

    # Used to predefined users and members
    PREDEFINED_NUM_NEWUSERS = 3
    PREDEFINED_NUM_APPLICANTS = 4
    PREDEFINED_NUM_MEMBERS = 2
    PREDEFINED_NUM_LAPSEDMEMBERS = 3
    PREDEFINED_NUM_FORMERMEMBERS = 2

    # Percentages used to create random users
    PERCENT_REGISTERED_USERS = 0.1
    PERCENT_CURRENT_MEMBERS = 0.55
    PERCENT_FORMER_MEMBERS = 0.15
    PERCENT_IN_GRACE_PD = 0.2

    RANDOM_PREFIX = 'Random'

    NEWUSER_LNAME = 'NewUser'
    RANDOM_NEWUSER_LNAME = "#{RANDOM_PREFIX}#{NEWUSER_LNAME}"

    APPLICANT_LNAME = 'Applicant'
    RANDOM_APPLICANT_LNAME = "#{RANDOM_PREFIX}#{APPLICANT_LNAME}"

    MEMBER_LNAME = 'Member'
    RANDOM_MEMBER_LNAME = "#{RANDOM_PREFIX}#{MEMBER_LNAME}"
    MEMBER_FNAME_PREFIX = 'Medlem-Exp'

    PAID_THRU_FNAME = 'PaidThrough'

    GRACEPERIODMEMBER_LNAME = 'InGracePeriod'
    RANDOM_GRACEPERIODMEMBER_LNAME ="#{RANDOM_PREFIX}#{GRACEPERIODMEMBER_LNAME}"
    GRACEPERIODMEMEBER_FNAME_PREFIX = 'Försenad-Exp'

    FORMERMEMBER_LNAME = 'FormerMember'
    RANDOM_FORMERMEMBER_LNAME = "#{RANDOM_PREFIX}#{FORMERMEMBER_LNAME}"
    FORMERMEMBER_FNAME_PREFIX = 'TidigareMedlem-Exp'

    DUMMY_EMAIL_DOMAIN = 'example.com'

    # --------------------------------------------------------------------------------------------

    def self.seed_predefined_users
      make_predefined_new_registered_users
      make_predefined_applicants
      make_predefined_current_members
      make_predefined_in_grace_period_members
      make_predefined_former_members
    end


    # New users are those that have signed up, but not submitted any application or done anything else.
    #   (They have not agreed to any Ethical Guidelines, etc.)
    def self.make_predefined_new_registered_users
      make_predefined_with(lastname: NEWUSER_LNAME, number: PREDEFINED_NUM_NEWUSERS)
    end


    # Applicants have created a new application (but the application has not been reviewed).  Some
    #   percentage have done 'other' requirements. (As of 2020-12-10,there is only one 'other'
    #   requirement:  agree to the Ethical Guidelines.  But there could be additional requirements
    #   in the future.)
    # ShfApplications and Companies are created for the applicants
    def self.make_predefined_applicants
      make_predefined_with(lastname: APPLICANT_LNAME, number: PREDEFINED_NUM_APPLICANTS) do |applicant|
        make_n_save_app(applicant, MA_NEW_STATE)
      end
    end


    # Current members are those that have met all of the requirements for membership and have
    #   paid.  Some percentage have paid in advance (for more than 1 membership term).
    # ShfApplications and Companies are created for the members.
    def self.make_predefined_current_members
      make_member_paid_through(Date.current + 1.day)
      make_member_paid_through(Date.current + 1.month)

      earliest_renew_days = MembershipsManager.days_can_renew_early
      make_member_paid_through(Date.current + earliest_renew_days)
      make_member_paid_through(Date.current + earliest_renew_days + 1)
      make_member_paid_through(Date.current + earliest_renew_days - 1)

      make_member_paid_through(Date.current + 6.months)
      make_member_paid_through(Date.current + 2.years - 1.day, term_first_day: Date.current)
    end


    # Members with payments overdue are those who are in the 'grace period'.
    # They may or may not have completed all of the requirements for renewing membership for the
    # membership term. Ex: If the requirement for renewing membership includes "must upload at least
    # 1 file" they may or may not have done that.  The requirements for renewing membership are
    # separate from payments.
    def self.make_predefined_in_grace_period_members
      grace_pd_first_day = Date.current - MembershipsManager.grace_period + 1.day
      make_member_paid_through(grace_pd_first_day, lastname: GRACEPERIODMEMBER_LNAME,
                               firstname_prefix: 'GracePeriod-plus-1day')
      make_member_paid_through(grace_pd_first_day + 1.month, lastname: GRACEPERIODMEMBER_LNAME,
                               firstname_prefix: 'GracePeriod-plus-1month')
      make_member_paid_through(Date.today - 1.day, lastname: GRACEPERIODMEMBER_LNAME,
                               firstname_prefix: 'GracePeriod-since')
    end


    # Former members are those whose last payment date has past AND they are past the 'grace period'
    #   as well.
    def self.make_predefined_former_members
      most_recent_last_day = Date.current - MembershipsManager.grace_period
      make_member_paid_through(most_recent_last_day - 1.day,
                               lastname: FORMERMEMBER_LNAME,
                               firstname_prefix: FORMERMEMBER_FNAME_PREFIX)
      make_member_paid_through(most_recent_last_day - 2.days,
                               lastname: FORMERMEMBER_LNAME,
                               firstname_prefix: FORMERMEMBER_FNAME_PREFIX)
    end


    def self.seed_random_users(num_users = 0)
      return if num_users == 1

      # make at least one applicant
      make_random_applicant(1)

      # users with no application (or zero if we are creating fewer than 3 total)
      users_with_no_application = num_users < 3 ? 0 : [1, (PERCENT_REGISTERED_USERS * num_users).round].max
      make_random_new_registered_user(users_with_no_application)

      users_with_application = num_users - users_with_no_application - 1
      return if users_with_application == 0

      num_current_members = (users_with_application * PERCENT_CURRENT_MEMBERS).round
      make_random_current_member(num_current_members)
      num_former_members = (users_with_application * PERCENT_FORMER_MEMBERS).round
      make_random_former_member(num_former_members)
      num_in_grace_pd = (users_with_application * PERCENT_IN_GRACE_PD).round
      make_random_in_grace_period(num_in_grace_pd)

      # the rest should be applicants, the application status chosen at random (excluding 'accepted')
      num_applicants = users_with_application - num_current_members - num_former_members -
        num_in_grace_pd - 1
      make_random_applicant(num_applicants)
    end


    def self.make_random_new_registered_user(num_users = 1)
      make_predefined_with(lastname: RANDOM_NEWUSER_LNAME, number: num_users)
    end


    def self.make_random_applicant(num_applicants = 1)
      num_applicants.times do |i|
        make_predefined_with(firstname:"#{FFaker::NameSE.first_name}#{i}",
                             lastname: RANDOM_APPLICANT_LNAME) do |applicant|
          make_n_save_app(applicant, random_application_not_accepted_state)
        end
      end
    end


    def self.make_random_current_member(num_members = 1)
      term_length_days = term_length_to_days
      num_members.times do |i|
        days_left_in_term = Random.rand(0..(term_length_days - 1))
        make_member_paid_through(Date.current + days_left_in_term.day,
                                 firstname_prefix: "#{MEMBER_FNAME_PREFIX}#{i}",
                                 lastname: RANDOM_MEMBER_LNAME)
      end
    end


    def self.make_random_in_grace_period(num_grace_pds = 1)
      grace_pd_days = grace_period_to_days
      num_grace_pds.times do |i|
        last_day = Date.current - Random.rand(1..(grace_pd_days - 1))
        make_member_paid_through(last_day,
                                 firstname_prefix: "#{GRACEPERIODMEMEBER_FNAME_PREFIX}#{i}",
                                 lastname: RANDOM_GRACEPERIODMEMBER_LNAME)
      end
    end


    def self.make_random_former_member(num_former_members = 1)
      num_former_members.times do |i|
        last_day = Date.current - MembershipsManager.grace_period - (Random.rand(1..700))
        make_member_paid_through(last_day,
                                 firstname_prefix: "#{FORMERMEMBER_FNAME_PREFIX}#{i}",
                                 lastname: RANDOM_FORMERMEMBER_LNAME)
      end
    end


    def self.make_member_paid_through(term_last_day, lastname: MEMBER_LNAME,
                                      number: 1,
                                      firstname_prefix: PAID_THRU_FNAME,
                                      term_first_day: nil,
                                      membership_status: :current_member)
      make_predefined_with(lastname: lastname, number: number, firstname: "#{firstname_prefix}-#{term_last_day.iso8601}") do |member|
        term_first_day = term_first_day.nil? ? Membership.first_day_from_last(term_last_day) : term_first_day

        make_n_save_app(member, MA_ACCEPTED_STATE) # Make application
        member.reload

        # Create the Ethical Guidelines checklist and complete it
        guidelines_list = UserChecklistManager.find_or_create_membership_guidelines_list_for(member)
        guidelines_list.set_complete_including_children(term_first_day)

        # Upload a file
        membership_app = member.shf_application
        uploaded_file_name = 'dog_emoji_cocker_spaniel.jpg'
        File.open(File.join(__dir__, uploaded_file_name), 'r') do |f|
          uploaded_file = UploadedFile.create!(user: member,
                                               shf_application: membership_app,
                                               actual_file: f,
                                               actual_file_file_name: uploaded_file_name)
          membership_app.uploaded_files << uploaded_file
        end

        # Make payments
        member.payments << new_membership_payment(member, term_first_day, term_last_day)
        member.companies.first.payments << new_hmarkt_payment(member, term_first_day, term_last_day)

        if member.current_membership
          member.most_recent_membership&.update(first_day: term_first_day, last_day: term_last_day)
        else
          member.start_membership_on(date: term_first_day, send_email: false)
        end
        member.update(membership_status: membership_status)
        member.reload

        MembershipStatusUpdater.instance.update_membership_status(member, send_email: false)
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
      "#{firstname.gsub(/(\s)+/, '-').downcase}@#{DUMMY_EMAIL_DOMAIN}"
    end


    def self.term_length_to_days
      Membership.term_length.to_i / 1.day.to_i
    end

    def self.grace_period_to_days
      MembershipsManager.grace_period.to_i / 1.day.to_i
    end


    def self.new_membership_payment(user, term_first_day, term_last_day)
         Payment.create(payment_type: Payment::PAYMENT_TYPE_MEMBER,
                                            user_id:      user.id,
                                            hips_id:      'none',
                                            status:       Payment::SUCCESSFUL,
                                            start_date:   term_first_day,
                                            expire_date:  term_last_day)
    end


    def self.new_hmarkt_payment(user, term_first_day, term_last_day)
      Payment.create(payment_type: Payment::PAYMENT_TYPE_BRANDING,
                     user_id:      user.id,
                     company_id:   user.companies.first.id,
                     hips_id:      'none',
                     status:       Payment::SUCCESSFUL,
                     start_date:   term_first_day,
                     expire_date:  term_last_day)
    end
  end

end
