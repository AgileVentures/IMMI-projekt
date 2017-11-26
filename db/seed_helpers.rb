module SeedHelper

  # The tests of defined? below are due to the rspec file that executes the seed file
  # repeatedly.  Without this, rspec complains about "already initialized constant"

  SEED_ERROR_MSG = 'Seed ERROR: Could not load either admin email or password.' +
                   ' NO ADMIN was created!' unless defined?(SEED_ERROR_MSG)

  MA_ACCEPTED_STATE = :accepted unless defined?(MA_ACCEPTED_STATE)

  FIRST_MEMBERSHIP_NUMBER = 100 unless defined?(FIRST_MEMBERSHIP_NUMBER)

  class SeedAdminENVError < StandardError
  end

  def env_invalid_blank(env_key)
    env_val = nil
    raise SeedAdminENVError, SEED_ERROR_MSG if
      ENV[env_key].nil? || (env_val = ENV.fetch(env_key)).blank?
    env_val
  end


  def get_company_number(r)
    company_number = nil
    100.times do
      # loop until done or we find a valid Org number
      org_number = Orgnummer.new(r.rand(1000000000..9999999999).to_s)
      next unless org_number.valid?

      # keep going if number already used
      unless MembershipApplication.find_by_company_number(org_number.number)
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
    users_with_double_application = small_number_of_users

    users_with_single_application = users.count - users_with_no_application - users_with_double_application

    users_with_application = users_with_single_application + users_with_double_application

    return if users_with_application == 0

    users[0..users_with_application-1].each.with_index do |user, i|
      make_application(user)
      make_application(user) unless i >= users_with_double_application
    end

  end

  #---
  # Create a membership application.
  #
  # with about a 30% chance, make an accepted application
  # with about a 70% chance, make an application with a status chosen randomly (but not yet accepted)
  #

  def make_application(user)

    if Random.new.rand(1.0) < 0.3 then
      # set the state to accepted for about 30% of the applications
      state = MA_ACCEPTED_STATE
    else
      # set a random state (except accepted) for the rest of the applications
      states = MembershipApplication.aasm.states.map(&:name) - [MA_ACCEPTED_STATE]
      state = FFaker.fetch_sample( states )
    end

    make_n_save_app(user, state)

  end


  def make_n_save_app(user, state, co_number = get_company_number(Random.new))
    # create a basic app
    ma = make_app(user, co_number )

    ma.state = state

    if state == MA_ACCEPTED_STATE then
      # make a full company object (instance) for the accepted membership application
      ma.company = make_new_company(ma.company_number)

      user.grant_membership

      start_date, expire_date = User.next_membership_payment_dates(user.id)

      user.payments << Payment.create(payment_type: Payment::PAYMENT_TYPE_MEMBER,
                                      user_id: user.id,
                                      hips_id: 'none',
                                      status: Payment.order_to_payment_status('successful'),
                                      start_date: start_date,
                                      expire_date: expire_date)
    end


    # ensure that this is the *last* application for the user
    user.membership_applications << ma

    user.save!
    user
  end


  def make_new_company(company_number)

    regions = Region.all.to_a
    kommuns = Kommun.all.to_a

    num_regions = regions.size
    num_kommuns = kommuns.size

    # make a full company instance
    company = Company.new(company_number: company_number,
                          email: FFaker::InternetSE.disposable_email,
                          name: FFaker::CompanySE.name,
                          phone_number: FFaker::PhoneNumberSE.phone_number,
                          website: FFaker::InternetSE.http_url)
    if(company.save)

      address = Address.new(addressable: company,
                            city: FFaker::AddressSE.city,
                            street_address: FFaker::AddressSE.street_address,
                            post_code: FFaker::AddressSE.zip_code,
                            region: regions[FFaker.rand(0..num_regions-1)],
                            kommun: kommuns[FFaker.rand(0..num_kommuns-1)],
                            visibility: 'street_address')

      address.save
    end

    company
  end


  def make_app(u, company_number)

    r = Random.new

    business_categories = BusinessCategory.all.to_a

    # for 1 in 8 apps, use a different contact email than the user's email
    ma = MembershipApplication.new(contact_email: ( (Random.new.rand(1..8)) == 0 ? FFaker::InternetSE.disposable_email : u.email),
                                   company_number: company_number,
                                   user: u)

    # add 1 to 3 business_categories, picked at random from them
    cats = FFaker.fetch_sample(business_categories, { count: (r.rand(1..3)) })

    cats.each do | category |
      ma.business_categories << category
    end

    ma
  end
end
