# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command
# (or created alongside the database with db:setup).

require 'ffaker'
require 'rake'
require_relative 'seed_helpers'
include SeedHelper

# The test of defined? is due to the rspec file that executes the seed file
# repeatedly.  Without this, rspec complains about "already initialized constant"
SEED_STOP_MSG = '<<< SEEDING STOPPED' unless defined?(SEED_STOP_MSG)

SEED_COMPLETE_MSG = '<<< SEEDING COMPLETED' unless defined?(SEED_COMPLETE_MSG)

SEED_USERS = 100 unless defined?(SEED_USERS)

DEFAULT_PASSWORD = 'whatever' unless defined?(DEFAULT_PASSWORD)

unless Rails.env.development? || Rails.env.production? ||
       Rails.env.test?        || ENV['HEROKU_STAGING']

  puts 'Unknown Rails environment !!'
  abort SEED_STOP_MSG
end

puts ">>> SEEDING ENVIRONMENT: #{Rails.env}"

if !Region.exists?
  puts 'Loading regions'
  Rake::Task['shf:load_regions'].invoke
end

if !Kommun.exists?
  puts 'Loading kommuns'
  Rake::Task['shf:load_kommuns'].invoke
end

puts 'Creating business categories'
business_categories = %w(Träning Psykologi Rehab Butik Trim Friskvård Dagis Pensionat Skola)
business_categories.each { |b_category| BusinessCategory.find_or_create_by(name: b_category) }
BusinessCategory.find_or_create_by(name: 'Sociala tjänstehundar', description: 'Terapi-, vård- & skolhund dvs hundar som jobbar tillsammans med sin förare/ägare inom vård, skola och omsorg.')
BusinessCategory.find_or_create_by(name: 'Civila tjänstehundar', description: 'Assistanshundar dvs hundar som jobbar åt sin ägare som service-, signal, diabetes, PH-hund mm')

puts 'Creating admin user'
if Rails.env.production?
  begin
    email = env_invalid_blank('SHF_ADMIN_EMAIL')
    pwd = env_invalid_blank('SHF_ADMIN_PWD')

    User.create!(email: email, password: pwd, admin: true,
                 first_name: 'SHF', last_name: 'Admin')
  rescue => e
    puts e.inspect
    puts SEED_STOP_MSG
    raise
  end
else
  email = 'admin@sverigeshundforetagare.se'
  pwd = 'hundapor'
  User.create(email: email, password: pwd, admin: true,
              first_name: 'SHF', last_name: 'Admin')
end

if Rails.env.development? || Rails.env.staging? || ENV['HEROKU_STAGING']

  puts 'Creating additional users ...'

  number_of_users = (ENV['SHF_SEED_USERS'] || SEED_USERS).to_i

  users = {}
  while users.length < number_of_users-1 do
    email = FFaker::InternetSE.disposable_email
    first_name = FFaker::NameSE.first_name
    last_name = FFaker::NameSE.last_name
    users[email] = User.create!(email: email, password: DEFAULT_PASSWORD,
                                first_name: first_name,
                                last_name: last_name) unless users.key?(email)
  end

  puts "Users created: #{User.count}"

  puts "\nCreating membership applications ..."
  puts "  As companies are created for accepted applications, their address has to be geocoded/located."
  puts "  This takes time to do. Be patient. (You can look at the /log/development.log to be sure that things are happening and this is not stuck.)"

  make_applications(users.values)

  puts "\n  Membership applications created: #{MembershipApplication.count}"
  puts "  Membership Applications by state:"
  states = MembershipApplication.aasm.states.map(&:name)
  states.sort.each do | state |
    puts "  #{state}: #{MembershipApplication.where(state: state).count }"
  end
end

puts SEED_COMPLETE_MSG
