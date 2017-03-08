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
    NUM_USERS = 100
    num_regions = regions.size
    num_kommuns = kommuns.size

    # Create users
    users = []

    NUM_USERS.times do
      users << User.create(email: FFaker::InternetSE.free_email,
                           password: DEFAULT_PASSWORD)
    end

    puts "Users created: #{NUM_USERS}"

    # Create membership application for some users
    # (two rounds - so some of the users have more than one application)

    business_categories = BusinessCategory.all.to_a
    num_cats = business_categories.size

    applications = []

    puts "Now creating membership applications."
    puts "  As companies are created for accepted applications, their address has to be geocoded/located."
    puts "  This takes time to do. Be patient. (You can look at the /log/development.log to be sure that things are happening and this is not stuck.)"

    2.times do
      r.rand(1..NUM_USERS).times do |i|

        next unless (company_number = get_company_number(r))

        u = users[r.rand(0..NUM_USERS-1)]

        #  If the user already has a membership application, use the same names.
          # (They would only use different name if they made a mistake and submitted a whole new application.  We won't worry about that case here.)
        if (m = MembershipApplication.find_by(user_id: u.id))
          first_n = m.first_name
          last_n = m.last_name
        else
          first_n = FFaker::NameSE.first_name
          last_n = FFaker::NameSE.last_name
        end

        # Every 6th user has a different membership application contact email than the email they use to log in to SHF
        ma = MembershipApplication.new(first_name: first_n,
                                       last_name: last_n,
                                       contact_email: (i.divmod(6).last == 0 ? FFaker::InternetSE.free_email : u.email),
                                       company_number: company_number,
                                       user: u)

        idx1 = r.rand(0..num_cats-1)
        ma.business_categories << business_categories[idx1]
        idx2 = r.rand(0..num_cats-1)
        ma.business_categories << business_categories[idx2] if idx2 != idx1
        idx3 = r.rand(0..num_cats-1)
        ma.business_categories << business_categories[idx3] if (idx3 != idx1 && idx3 != idx2)

        ma.save

        applications << ma
      end
    end

    puts "Applications created: #{MembershipApplication.all.count}"

    #---
    # Membership Application status

    # Ensure we have a good variation of different statuses (some accepted, some rejected, etc.)

    #  We're most interested in accepted applications, so first make <some random number> of those

    r.rand(1..applications.size).times do

      ma = applications[r.rand(0..(applications.size-1))]

      next if ma.is_accepted?

      ma.state = MA_ACCEPTED_STATE
      ma.user.save

      company = Company.new(company_number: ma.company_number,
                            email: FFaker::InternetSE.free_email,
                            name: FFaker::CompanySE.name,
                            phone_number: FFaker::PhoneNumberSE.phone_number,
                            website: FFaker::InternetSE.http_url)
      company.save

      address = Address.new(addressable: company,
                            city: FFaker::AddressSE.city,
                            street_address: FFaker::AddressSE.street_address,
                            post_code: FFaker::AddressSE.zip_code,
                            region: regions[r.rand(0..num_regions-1)],
                            kommun: kommuns[r.rand(0..num_kommuns-1)])

      address.save

      ma.company = company
      ma.save
    end

    #  Then with the remaining applications, evenly distribute the remaining states:

    remaining_apps = MembershipApplication.where.not(state: MA_ACCEPTED_STATE)

    remaining_states = MembershipApplication.aasm.states.map(&:name) - [MA_ACCEPTED_STATE]

    remaining_apps.each_with_index do | app, i |

      # distribute the remaining possible states equally
      app.update(state: remaining_states[ i.divmod(remaining_states.count).last  ] )

    end

    puts "Membership Applications by state:"
    states = remaining_states +  [MA_ACCEPTED_STATE]
    states.sort.each do | state |
      puts "  #{state}: #{MembershipApplication.where(state: state).count }"
    end

  end
end
