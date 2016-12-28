# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

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

# This populates the 'regions' table for Swedish regions (aka counties),
# as well as 'Sweden' and 'Online'.  This is used to specify the primary
# region in which a company operates.
#
# This uses the 'city-state' gem for a list of regions (name and ISO code).
# (That gem will also return a list of cities within region)
#
# If the regions table is not empty, do not run this code unless there
# are also no companies, as the region ID's will be reset.
if Region.exists?
  CS.states(:se).each_pair { |k,v| Region.create(name: v, code: k.to_s) }
  Region.create(name: 'Sweden', code: nil)
  Region.create(name: 'Online', code: nil)
end

business_categories = %w(Träning Psykologi Rehab Butik Trim Friskvård Dagis Pensionat Skola)
business_categories.each { |b_category| BusinessCategory.find_or_create_by(name: b_category) }
BusinessCategory.find_or_create_by(name: 'Sociala tjänstehundar', description: 'Terapi-, vård- & skolhund dvs hundar som jobbar tillsammans med sin förare/ägare inom vård, skola och omsorg.')
BusinessCategory.find_or_create_by(name: 'Civila tjänstehundar', description: 'Assistanshundar dvs hundar som jobbar åt sin ägare som service-, signal, diabetes, PH-hund mm')
