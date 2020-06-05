# require all *.rb files in these subdirectories under <Rails root>/db
require File.join(Rails.root, 'db/seed_helpers.rb')
required_subdirs = %w(seed_helpers seeders)
required_subdirs.each do | required_subdir |
  Dir[File.join(Rails.root, 'db', required_subdir, '**','*.rb')].each do |file|
    require file
  end
end
