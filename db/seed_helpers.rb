require_relative 'seed_helpers/address_factory.rb'
require 'smarter_csv'
require_relative('../lib/fake_addresses/csv_fake_addresses_reader')


module SeedHelper

  # The tests of defined? below are due to the rspec file that executes the seed file
  # repeatedly.  Without this, rspec complains about "already initialized constant"

  SEED_ERROR_MSG             = 'Seed ERROR: Could not load either admin email or password.' +
      ' NO ADMIN was created!' unless defined?(SEED_ERROR_MSG)

  MA_NEW_STATE          = :new unless defined?(MA_NEW_STATE)
  MA_UNDER_REVIEW_STATE = :under_review unless defined?(MA_UNDER_REVIEW_STATE)
  MA_WAITING_FOR_APPLICANT_STATE =
                          :waiting_for_applicant unless defined?(MA_WAITING_FOR_APPLICANT_STATE)
  MA_READY_FOR_REVIEW_STATE =
                          :ready_for_review unless defined?(MA_READY_FOR_REVIEW_STATE)
  MA_ACCEPTED_STATE     = :accepted unless defined?(MA_ACCEPTED_STATE)
  MA_REJECTED_STATE     = :rejected unless defined?(MA_REJECTED_STATE)

  MA_ACCEPTED_STATE_STR      = MA_ACCEPTED_STATE.to_s unless defined?(MA_ACCEPTED_STATE_STR)

  MA_BEING_DESTROYED_STATE   = :being_destroyed unless defined?(MA_BEING_DESTROYED_STATE)

  FIRST_MEMBERSHIP_NUMBER    = 100 unless defined?(FIRST_MEMBERSHIP_NUMBER)

  PERCENT_WITH_SENT_PACKETS = 60 unless defined?(PERCENT_WITH_SENT_PACKETS)


  class SeedAdminENVError < StandardError
  end

  attr_reader :regions, :kommuns, :business_categories
  attr_writer :address_factory

  # =============================================================================================

  # Initialize the instance vars
  #
  # @regions, @kommuns, and @business_categories are initialized using
  # lazy initialization - only when they're called.
  def init_generated_seeding_info
    @regions     = nil
    @kommuns     = nil
    @business_categories = nil
    @address_factory = AddressFactory.new(regions, kommuns)
  end


  def env_invalid_blank(env_key)
    env_val = nil
    raise SeedAdminENVError, SEED_ERROR_MSG if ENV[env_key].nil? || (env_val = ENV.fetch(env_key)).blank?
    env_val
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


  # @return [Symbol] - a randomly chosen ShfApplication state, excluding :accepted and :being_destroyed
  #
  def random_application_not_accepted_state
    states = ShfApplication.aasm.states.map(&:name) -
      [MA_ACCEPTED_STATE, MA_BEING_DESTROYED_STATE]
    FFaker.fetch_sample(states)
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
  def make_n_save_app(user, state, co_number = get_company_number)
    # Reset instance vars so AR records will be reloaded when run in TEST
    # (rspec DB tests load tasks but there is no "reload" available)
    @files_uploaded = nil
    @upload_later = nil
    @email = nil

    # Create a basic application and assign some random business categories
    app = make_app(user)

    app.companies = [] # We ensure that this association is present

    app.state = state

    app.file_delivery_method = get_delivery_method_for_app(state)
    app.file_delivery_selection_date = Date.current

    # make a full company object (instance) for the membership application
    app.companies << find_or_make_new_company(co_number)

    user.shf_application = app
    user.save!

    set_membership_packet_sent user
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
        user.update(date_membership_packet_sent: (Date.current - Random.rand(0..30)).to_time )
      end
    end

    user
  end


  def find_or_make_new_company(company_number)
    Company.find_or_create_by!(company_number: company_number) do | co |

      # make a full company instance and address
      co.company_number = company_number
      co.email =          FFaker::InternetSE.disposable_email
      co.name =           FFaker::CompanySE.name
      co.phone_number =   FFaker::PhoneNumberSE.phone_number
      co.website =        FFaker::InternetSE.http_url

      address_factory.make_n_save_a_new_address(co)
      co
    end
  end


  def make_app(user)
    # for 1 in 8 apps, use a different contact email than the user's email
    email = (Random.rand(1..8) == 0) ? FFaker::InternetSE.disposable_email : user.email

    app = ShfApplication.new(contact_email: email, user: user)

    # add 1 to 3 business_categories, picked at random from them
    cats = FFaker.fetch_sample(business_categories, { count: (Random.rand(1..3)) })

    cats.each do |category|
      app.business_categories << category
    end

    app
  end


  # use lazy initialization; cache all Regions
  def regions
    @regions ||= Region.all.to_a
  end

  # use lazy initialization; cache all Kommuns
  def kommuns
    @kommuns ||= Kommun.all.to_a
  end

  # use lazy initialization; cache all BusinessCategory
  def business_categories
    @business_categories ||= BusinessCategory.all.to_a
  end

  def address_factory
    @address_factory ||= AddressFactory.new(regions, kommuns)
  end

end
