module SeedHelper

  # The tests of defined? below are due to the rspec file that executes the seed file
  # repeatedly.  Without this, rspec complains about "already initialized constant"

  SEED_ERROR_MSG = 'Seed ERROR: Could not load either admin email or password.' +
                   ' NO ADMIN was created!' unless defined?(SEED_ERROR_MSG)

  DEFAULT_PASSWORD = 'whatever' unless defined?(DEFAULT_PASSWORD)

  MA_ACCEPTED_STATE = :accepted unless defined?(MA_ACCEPTED_STATE)

  NUM_USERS = 100 unless defined?(NUM_USERS)

  MAX_APPS_PER_USER = 4 unless defined?(MAX_APPS_PER_USER)

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


  #---
  # Create some number of membership applications for a user.
  #
  # for 10% users, do not make any applications (they are just registered Users)
  # for 60% users, just make 1 application with a status chosen randomly
  # for 30% users, make multiple applications
  #   randomly select some number, and randomly select a state for each application
  #     Note that if there is an accepted application, it must be the LAST one
  #      because the code currently assumes that if a member has a company, that
  #       company can be accessed via the LAST membership application (user.membership_applications.last)
  #
  def make_applications_for(user)

    num_apps = Random.new.rand(1..10)

    case num_apps
      when 1..6
        make_n_save_multiple_apps(user, MAX_APPS_PER_USER) # multiple applications
      when 7..9
        make_n_save_accepted_app(user)
      else # no app; do nothing.
    end

    user
  end


  # make 'num_apps' number of applications for a user, ensure that if there is
  # an accepted application, it is the LAST one
  def make_n_save_multiple_apps(user, max_apps)

    append_accepted_app = false

    company_number = get_company_number(Random.new)

    states = MembershipApplication.aasm.states.map(&:name)

    chosen_states = FFaker.fetch_sample( states, { count: (max_apps < states.count ? max_apps : states.count) } )

    if chosen_states.include? MA_ACCEPTED_STATE
      chosen_states = chosen_states - [MA_ACCEPTED_STATE]
      append_accepted_app = true
    end

    chosen_states.each do | app_state |
      ma = make_app(user, company_number)
      ma.state = app_state
      user.membership_applications << ma
    end

    user.save

    if append_accepted_app
      make_n_save_accepted_app(user, company_number)
    end

    user
  end


  def make_new_company(company_number)

    regions = Region.all.to_a
    kommuns = Kommun.all.to_a

    num_regions = regions.size
    num_kommuns = kommuns.size

    # make a full company instance
    company = Company.new(company_number: company_number,
                          email: FFaker::InternetSE.free_email,
                          name: FFaker::CompanySE.name,
                          phone_number: FFaker::PhoneNumberSE.phone_number,
                          website: FFaker::InternetSE.http_url,
                          address_visibility: 'street_address')
    if(company.save)

      address = Address.new(addressable: company,
                            city: FFaker::AddressSE.city,
                            street_address: FFaker::AddressSE.street_address,
                            post_code: FFaker::AddressSE.zip_code,
                            region: regions[FFaker.rand(0..num_regions-1)],
                            kommun: kommuns[FFaker.rand(0..num_kommuns-1)])

      address.save
    end

    company
  end


  def get_next_membership_number

    MembershipApplication.last.nil? ? FIRST_MEMBERSHIP_NUMBER : MembershipApplication.last.id + FIRST_MEMBERSHIP_NUMBER
  end


  def make_n_save_accepted_app(user, co_number = get_company_number(Random.new))

    # create a basic app
    ma = make_app(user, co_number )

    # set the state to accepted
    ma.state = MA_ACCEPTED_STATE

    # make a full company object (instance) for the accepted membership application
    ma.company = make_new_company(ma.company_number)

    ma.membership_number = get_next_membership_number

    # ensure that this is the *last* application for the user
    user.membership_applications << ma

    user.save
    user
  end


  #  If the user already has a membership application, use the same names.
  # (They would only use different name if they made a mistake and submitted
  #   a whole new application.  We won't worry about that case here.)
  def get_app_names(u)

    if (m = MembershipApplication.find_by(user_id: u.id))
      first_n = m.first_name
      last_n = m.last_name
    else
      first_n = FFaker::NameSE.first_name
      last_n = FFaker::NameSE.last_name
    end

    return first_n, last_n
  end


  def make_app(u, company_number)

    r = Random.new

    business_categories = BusinessCategory.all.to_a

    first_n, last_n = get_app_names(u)

    # for 1 in 8 apps, use a different contact email than the user's email
    ma = MembershipApplication.new(first_name: first_n,
                                   last_name: last_n,
                                   contact_email: ( (Random.new.rand(1..8)) == 0 ? FFaker::InternetSE.free_email : u.email),
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
