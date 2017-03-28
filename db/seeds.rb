# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'ffaker'

class SeedAdminENVError < StandardError
end

SEED_ERROR_MSG = 'Seed ERROR: Could not load either admin email or password. NO ADMIN was created!'

DEFAULT_PASSWORD = 'whatever'

MA_ACCEPTED_STATE = :accepted

NUM_USERS =  100

MAX_APPS_PER_USER = 4

FIRST_MEMBERSHIP_NUMBER = 100


# --------------------


private def env_invalid_blank(env_key)
  raise SeedAdminENVError, SEED_ERROR_MSG if (env_val = ENV.fetch(env_key)).blank?
  env_val
end


private def get_company_number(r)
  company_number = nil
  20.times do
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
private def make_applications_for(user)

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
private def make_n_save_multiple_apps(user, max_apps)

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


private def make_new_company(company_number)

  regions = Region.all.to_a
  kommuns = Kommun.all.to_a

  num_regions = regions.size
  num_kommuns = kommuns.size

  # make a full company instance
  company = Company.new(company_number: company_number,
                        email: FFaker::InternetSE.free_email,
                        name: FFaker::CompanySE.name,
                        phone_number: FFaker::PhoneNumberSE.phone_number,
                        website: FFaker::InternetSE.http_url)
  company.save

  address = Address.new(addressable: company,
                        city: FFaker::AddressSE.city,
                        street_address: FFaker::AddressSE.street_address,
                        post_code: FFaker::AddressSE.zip_code,
                        region: regions[FFaker.rand(0..num_regions-1)],
                        kommun: kommuns[FFaker.rand(0..num_kommuns-1)])

  address.save

  company
end


private def get_next_membership_number

  MembershipApplication.last.nil? ? FIRST_MEMBERSHIP_NUMBER : MembershipApplication.last.id + FIRST_MEMBERSHIP_NUMBER
end


private def make_n_save_accepted_app(user, co_number = get_company_number(Random.new))

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
private def get_app_names(u)

  if (m = MembershipApplication.find_by(user_id: u.id))
    first_n = m.first_name
    last_n = m.last_name
  else
    first_n = FFaker::NameSE.first_name
    last_n = FFaker::NameSE.last_name
  end

  return first_n, last_n
end


private def make_app(u, company_number)

  r = Random.new

  business_categories = BusinessCategory.all.to_a
  num_cats = business_categories.size

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


#---------------------------



if Rails.env.production?
  begin
    email = env_invalid_blank('SHF_ADMIN_EMAIL')
    pwd = env_invalid_blank('SHF_ADMIN_PWD')

    User.create(email: email, password: pwd, admin: true)
  rescue
    raise SeedAdminENVError, SEED_ERROR_MSG
  end
else
  email = 'admin@sverigeshundforetagare.se'
  pwd = 'hundapor'
  User.create(email: email, password: pwd, admin: true)
end


require 'csv'

csv_text = File.read(Rails.root.join('lib', 'seeds', 'user_table.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
csv.each do |row|
  User.find_or_create_by(email: row['email']) do |user|
    user.password = DEFAULT_PASSWORD
  end
end


business_categories = %w(Träning Psykologi Rehab Butik Trim Friskvård Dagis Pensionat Skola)
business_categories.each { |b_category| BusinessCategory.find_or_create_by(name: b_category) }
BusinessCategory.find_or_create_by(name: 'Sociala tjänstehundar', description: 'Terapi-, vård- & skolhund dvs hundar som jobbar tillsammans med sin förare/ägare inom vård, skola och omsorg.')
BusinessCategory.find_or_create_by(name: 'Civila tjänstehundar', description: 'Assistanshundar dvs hundar som jobbar åt sin ägare som service-, signal, diabetes, PH-hund mm')

if Rails.env.development? || Rails.env.staging? || ENV['HEROKU_STAGING']

  regions = Region.all.to_a

  if regions.empty?
    puts "Run task 'shf:load_regions' before seeding if you want records created for"
    puts 'users, members, membership_applications, business categories and companies.'
  else
    kommuns = Kommun.all.to_a

    puts 'Seeding the db with users...'

    r = Random.new

    # Create users
    users = []

    NUM_USERS.times do
      users << User.create(email: FFaker::InternetSE.free_email,
                           password: DEFAULT_PASSWORD)
    end

    puts "Users created: #{NUM_USERS}"


    puts "\nNow creating membership applications."
    puts "  As companies are created for accepted applications, their address has to be geocoded/located."
    puts "  This takes time to do. Be patient. (You can look at the /log/development.log to be sure that things are happening and this is not stuck.)"

    users.each { |u| make_applications_for u }


    puts "\n Membership Applications by state:"
    states = MembershipApplication.aasm.states.map(&:name)
    states.sort.each do | state |
      puts "  #{state}: #{MembershipApplication.where(state: state).count }"
    end

  end
end
