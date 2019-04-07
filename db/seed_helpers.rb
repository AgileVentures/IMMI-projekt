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

  DEFAULT_FAKE_ADDR_FILENAME = 'fake-addresses-89--2018-12-12.csv' unless defined?(DEFAULT_FAKE_ADDR_FILENAME)


  class SeedAdminENVError < StandardError
  end


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


  def make_applications(users)

    # make at least one accepted membership application
    user = users.delete_at(0)
    return if user == nil
    make_n_save_app(user, MA_ACCEPTED_STATE)

    small_number_of_users = users.count < 3 ? 0 : [1, (0.1 * users.count).round].max

    users_with_no_application = small_number_of_users

    users_with_application = users.count - users_with_no_application

    return if users_with_application == 0

    users[0..users_with_application - 1].each.with_index do |each_user|
      make_application(each_user)
    end

  end


  #---
  # Create a membership application.
  #
  # with about a 30% chance, make an accepted application
  # with about a 70% chance, make an application with a status chosen randomly (but not yet accepted)
  #

  def make_application(user)

    if Random.new.rand(1.0) < 0.3
      # set the state to accepted for about 30% of the applications
      state = MA_ACCEPTED_STATE
    else
      # set a random state for the rest of the applications (except accepted and being destroyed)
      states = ShfApplication.aasm.states.map(&:name) -
          [MA_ACCEPTED_STATE, MA_BEING_DESTROYED_STATE]

      state = FFaker.fetch_sample(states)
    end

    make_n_save_app(user, state)

  end


  def make_n_save_app(user, state, co_number = get_company_number)
    # Reset instance vars so AR records will be reloaded when run in TEST
    # (rspec DB tests load tasks but there is no "reload" available)
    @files_uploaded = nil
    @upload_later = nil
    @email = nil


    # create a basic app
    ma = make_app(user)

    ma.companies = [] # We validate that this association is present

    ma.state = state

    ma.file_delivery_method = get_delivery_method_for_app(state)
    ma.file_delivery_selection_date = Date.current

    # make a full company object (instance) for the membership application
    ma.companies << make_new_company(co_number)

    # Create payment records for accepted app and associated company
    if ma.state == MA_ACCEPTED_STATE_STR

      start_date, expire_date = User.next_membership_payment_dates(user.id)

      user.payments << Payment.create(payment_type: Payment::PAYMENT_TYPE_MEMBER,
                                      user_id:      user.id,
                                      hips_id:      'none',
                                      status:       Payment::SUCCESSFUL,
                                      start_date:   start_date,
                                      expire_date:  expire_date)

      start_date, expire_date = Company.next_branding_payment_dates(ma.companies[0].id)


      MembershipStatusUpdater.instance.check_requirements_and_act({ user: user, send_email: false })
      #user.update_action(send_email: false)

      ma.companies[0].payments << Payment.create(payment_type: Payment::PAYMENT_TYPE_BRANDING,
                                                 user_id:      user.id,
                                                 company_id:   ma.companies[0].id,
                                                 hips_id:      'none',
                                                 status:       Payment::SUCCESSFUL,
                                                 start_date:   start_date,
                                                 expire_date:  expire_date)
    end

    user.shf_application = ma

    user.save!
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


  def make_new_company(company_number)

    # make a full company instance
    company = Company.new(company_number: company_number,
                          email:          FFaker::InternetSE.disposable_email,
                          name:           FFaker::CompanySE.name,
                          phone_number:   FFaker::PhoneNumberSE.phone_number,
                          website:        FFaker::InternetSE.http_url)

    if company.save
      @address_factory.make_n_save_a_new_address(company)
    end

    company
  end


  def make_app(user)

    r = Random.new

    #business_categories = BusinessCategory.all.to_a

    # for 1 in 8 apps, use a different contact email than the user's email
    email = (Random.new.rand(1..8) == 0) ? FFaker::InternetSE.disposable_email : user.email

    ma = ShfApplication.new(contact_email: email, user: user)

    # add 1 to 3 business_categories, picked at random from them
    cats = FFaker.fetch_sample(business_categories, { count: (r.rand(1..3)) })

    cats.each do |category|
      ma.business_categories << category
    end

    ma
  end


  def load_app_config
    AdminOnly::AppConfiguration.create
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


  # ==========================================================================


  # Responsibility: Create a new address either from cached info or from scratch
  #
  # Create it from a list of already created addresses (=cached info),
  # or if that list is empty,
  # create it from Faker info.
  #
  # The list of already created addresses is read from a CSV file.
  # The CSV filename is from ENV['SHF_SEED_FAKE_ADDR_CSV_FILE'] or, if that
  # doesn't exist, the default CSV filename.
  #
  class AddressFactory


    def initialize(regions, kommuns)
      @regions = regions
      @kommuns = kommuns
      @fake_addresses_csv_filename   = nil
      @already_constructed_addresses = nil
    end


    def default_csv_filename
      DEFAULT_FAKE_ADDR_FILENAME
    end


    # Note that the CSV file is expected to be in this directory
    def fake_addresses_csv_filename
      @fake_addresses_csv_filename ||= File.join(__dir__, (ENV.fetch('SHF_SEED_FAKE_ADDR_CSV_FILE', default_csv_filename)))
    end


    # if needed, load addresses from the csv file of fake addresses
    def already_constructed_addresses
      @already_constructed_addresses ||= CSVFakeAddressesReader.read_from_csv_file(fake_addresses_csv_filename).shuffle
    end


    def num_regions
      @num_regions ||= @regions.size
    end


    def num_kommuns
      @num_kommuns ||= @kommuns.size
    end


    # Create a new address and save it
    #
    # First try to use an already constructed address.
    #
    # If there are no more already constructed addresses,
    # create a new address from scratch.
    #
    # Note that an address from the already constructed addresses must be save
    # _without_ validation.  Otherwise it will be geocoded, which defeats the
    # whole purpose of using an already constructed address.
    #
    def make_n_save_a_new_address(addressable_entity)

      if can_use_already_constructed_address?
        new_address = get_an_already_constructed_address(addressable_entity)
      else
        new_address = create_a_new_address(addressable_entity)
      end

      new_address
    end


    # @return [Boolean] - can we get an address from a list of already constructed
    #                     addresses?
    def can_use_already_constructed_address?
      !already_constructed_addresses.empty?
    end


    # Get an already constructed address, assign the addressable entity,
    # remove it from the list of already constructed addresses
    # and save it.
    #
    # If we cannot get an address, return nil
    #
    # We ensure that each address is used just once by
    # removing it from the list of already constructed addresses.
    #
    # @param addressable_entity [] - the addressable object that we will associate with the address
    # @return [Address] - an address that is saved but _not_ validated
    def get_an_already_constructed_address(addressable_entity)

      constructed_address = already_constructed_addresses.pop

      unless constructed_address.nil?
        constructed_address.addressable = addressable_entity
        constructed_address.save(validations: false)
      end

      constructed_address
    end


    # Create a new address.  This will have to be geocoded, which takes time.
    def create_a_new_address(addressable_entity)

      addr = Address.new(addressable:    addressable_entity,
                         city:           FFaker::AddressSE.city,
                         street_address: FFaker::AddressSE.street_address,
                         post_code:      FFaker::AddressSE.zip_code,
                         region:         @regions[FFaker.rand(0..(num_regions - 1))],
                         kommun:         @kommuns[FFaker.rand(0..(num_kommuns - 1))],
                         visibility:     'street_address')
      puts " Creating a new address: #{addr.street_address} #{addr.city}. (Will geolocate when saving it)"
      addr.save
      addr
    end

  end # AddressFactory

end # module SeedHelper
