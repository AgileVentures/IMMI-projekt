require_relative('../seed_helpers.rb')
require_relative '../require_all_seeders_and_helpers'

#--------------------------
#
# @class ShfApplicationFactory
#
# @desc Responsibility: create ShfApplications
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   6/23/21
#
#--------------------------

module SeedHelpers
  class ShfApplicationFactory

    def initialize(static_data = SeedHelper::StaticDataFactory.new, log = nil)
      @static_data = static_data
      @log = log
    end


    # Create a SHF Application for the user and set the application
    # to the given :state.
    # If the company for co_number does not yet exist, create it. (find_or_create!(company_number: ...)).
    #
    # Set the file delivery method for the user and then finally
    # set when the membership packet was sent to the user (as
    # applicable depending on the application state).
    #
    # save the user
    #
    # @param user [User] - the user
    # @param state [String] - the state to put the Shf Application in
    # @param co_number [String] - the Company Number (Org nummer) for
    #   the company associated with the user; needed for the application
    #
    # @return [User] - the user
    def make_n_save_app(user, state, co_number = get_company_number, acceptance_date: Date.current)
      # Reset instance vars so AR records will be reloaded when run in TEST
      # (rspec DB tests load tasks but there is no "reload" available)
      @files_uploaded = nil
      @upload_later = nil
      @email = nil

      # Create a basic application and assign some random business categories
      app = make_app(user)

      app.companies = [] # We ensure that this association is present

      app.state = state
      app.update(when_approved: acceptance_date) if app.accepted?

      app.file_delivery_method = get_delivery_method_for_app(state)
      app.file_delivery_selection_date = acceptance_date

      # make a full company object (instance) for the membership application
      app.companies << find_or_make_new_company(co_number)

      user.shf_application = app
      user.save!

      set_membership_packet_sent user
      user
    end


    # -------------------------------------------------------------------------------------------
    private

    def make_app(user)
      # for 1 in 8 apps, use a different contact email than the user's email
      email = (Random.rand(1..8) == 0) ? FFaker::InternetSE.disposable_email : user.email

      app = ShfApplication.new(contact_email: email, user: user)

      # add 1 to 3 business_categories, picked at random from them
      cats = FFaker.fetch_sample(@static_data.business_categories, { count: (Random.rand(1..3)) })

      cats.each do |category|
        app.business_categories << category
      end

      app
    end


    def find_or_make_new_company(company_number)
      Company.find_or_create_by!(company_number: company_number) do |co|

        # make a full company instance and address
        co.company_number = company_number
        co.email = FFaker::InternetSE.disposable_email
        co.name = FFaker::CompanySE.name
        co.phone_number = FFaker::PhoneNumberSE.phone_number
        co.website = FFaker::InternetSE.http_url

        @static_data.address_factory.make_n_save_a_new_address(co)
        co
      end
    end


    # If the user is a member, set a date for when the membership
    # packet was sent -- about <PERCENT_WITH_SENT_PACKETS>% of the time.
    # (It is left blank for the other %, which means it has not been sent.)
    #
    # Choose a random date within the last 30 days
    #
    # update (save) the user if the :date_membership_packet_sent was set
    #
    # @param user [User] - the user to check and possible set the :date_membership_packet_sent for
    # @return [User] - return the user
    def set_membership_packet_sent(user)

      if user.shf_application.accepted?
        if Random.rand(100) <= PERCENT_WITH_SENT_PACKETS
          user.update(date_membership_packet_sent: (Date.current - Random.rand(0..30)).to_time)
        end
      end

      user
    end


    def get_delivery_method_for_app(state)
      klass = AdminOnly::FileDeliveryMethod

      case state

        when MA_ACCEPTED_STATE, MA_REJECTED_STATE, MA_READY_FOR_REVIEW_STATE
          @files_uploaded ||= klass.get_method(:files_uploaded)

        when MA_NEW_STATE, MA_WAITING_FOR_APPLICANT_STATE
          @upload_later ||= klass.get_method(:upload_later)

        when MA_UNDER_REVIEW_STATE
          @email ||= klass.get_method(:email)
      end
    end


    def get_company_number(r = Random.new)
      company_number = nil
      100.times do
        # loop until done or we find a valid Org number
        org_number = Orgnummer.new(r.rand(1000000000..9999999999).to_s)
        next unless org_number.valid?

        # keep going if number already used
        unless Company.find_by_company_number(org_number.number)
          company_number = org_number.number
          break
        end
      end
      company_number
    end

  end
end
