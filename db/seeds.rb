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

private def env_invalid_blank(env_key)
  raise SeedAdminENVError, SEED_ERROR_MSG if (env_val = ENV.fetch(env_key)).blank?
  env_val
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
    user.password = 'whatever'
  end
end

business_categories = %w(Träning Psykologi Rehab Butik Trim Friskvård Dagis Pensionat Skola)
business_categories.each { |b_category| BusinessCategory.find_or_create_by(name: b_category) }
BusinessCategory.find_or_create_by(name: 'Sociala tjänstehundar', description: 'Terapi-, vård- & skolhund dvs hundar som jobbar tillsammans med sin förare/ägare inom vård, skola och omsorg.')
BusinessCategory.find_or_create_by(name: 'Civila tjänstehundar', description: 'Assistanshundar dvs hundar som jobbar åt sin ägare som service-, signal, diabetes, PH-hund mm')

if Rails.env.development? || Rails.env.staging?
  r = Random.new
  USERS = 40
  regions = Region.all.to_a # regions are created in a migration file
  num_regions = regions.size

  # Create users
  users = []

  USERS.times do
    users << User.create(email: FFaker::InternetSE.free_email,
                         password: 'password')
  end

  puts "Users created: #{User.all.count}"

  # Create membership application for some users
  # (two rounds - so some of the users have more than one application)

  business_categories = BusinessCategory.all.to_a
  num_cats = business_categories.size

  applications = []

  2.times do |idx|
    r.rand(1..USERS).times do
      company_number = r.rand(1000000000..9999999999).to_s

      ma = MembershipApplication.new(first_name: FFaker::NameSE.first_name,
                                     last_name: FFaker::NameSE.last_name,
                                     contact_email: FFaker::InternetSE.free_email,
                                     company_number: company_number,
                                     status: 'Pending',
                                     user: users[idx])
      idx1 = r.rand(0..num_cats-1)
      ma.business_categories << business_categories[idx1]
      idx2 = r.rand(0..num_cats-1)
      ma.business_categories << business_categories[idx2] if idx2 != idx1

      ma.save(validate: false)

      applications << ma
    end
  end

  puts "Applications created: #{MembershipApplication.all.count}"

  # Accept some of the membership applications
  r.rand(0..(applications.size-1)).times do |idx|
    ma = applications[idx]
    ma.status = 'Godkänd'
    ma.user.is_member = true
    ma.user.save

    company = Company.new(company_number: ma.company_number,
                       email: FFaker::InternetSE.free_email,
                       name: FFaker::CompanySE.name,
                       phone_number: FFaker::PhoneNumberSE.phone_number,
                       city: FFaker::AddressSE.city,
                       street: FFaker::AddressSE.street_address,
                       post_code: FFaker::AddressSE.zip_code,
                       website: FFaker::InternetSE.http_url,
                       region: regions[r.rand(0..num_regions-1)])
    company.save(validate: false)
    ma.company = company
    ma.save(validate: false)
  end

  puts "Applications accepted: #{MembershipApplication
    .where(status: 'Godkänd').count}"
end
