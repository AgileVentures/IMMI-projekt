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

NUM_USERS = 100 unless defined?(NUM_USERS)

NUM_USERS_WITH_ONE_APPLICATION =  90 unless defined?(NUM_USERS_WITH_ONE_APPLICATION)

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

    User.create!(email: email, password: pwd, admin: true)
  rescue => e
    puts e.inspect
    puts SEED_STOP_MSG
    raise
  end
else
  email = 'admin@sverigeshundforetagare.se'
  pwd = 'hundapor'
  User.create(email: email, password: pwd, admin: true)
end

unless Rails.env.production? || Rails.env.test?

  puts 'Creating additional users ...'

  users = {}
  while users.length < NUM_USERS-1 do
    email = FFaker::InternetSE.free_email
    users[email] = User.create!(email: email, password: DEFAULT_PASSWORD) unless users.key?(email)
  end

  puts "Users created: #{User.count}"

  puts "\nCreating membership applications ..."
  puts "  As companies are created for accepted applications, their address has to be geocoded/located."
  puts "  This takes time to do. Be patient. (You can look at the /log/development.log to be sure that things are happening and this is not stuck.)"

  make_applications(users.values, NUM_USERS_WITH_ONE_APPLICATION)

  puts "\n  Membership applications created: #{MembershipApplication.count}"
  puts "  Membership Applications by state:"
  states = MembershipApplication.aasm.states.map(&:name)
  states.sort.each do | state |
    puts "  #{state}: #{MembershipApplication.where(state: state).count }"
  end
end

puts SEED_COMPLETE_MSG
