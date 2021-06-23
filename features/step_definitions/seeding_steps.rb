require File.join(Rails.root, 'db/require_all_seeders_and_helpers.rb')

Given(/^There are no "([^"]*)" records in the db$/) do | models|
  model_klass = ActiveSupport::Inflector.singularize(models)
  eval "#{model_klass}.delete_all"
end

When(/^the system is seeded with initial data$/) do

  allow(Seeders::YamlSeeder).to receive(:tell).and_return(false)
  allow_any_instance_of(ActivityLogger).to receive(:show).and_return(false)

  allow_any_instance_of(SeedHelpers::AddressFactory).to receive(:tell).and_return(false)

  SHFProject::Application.load_tasks
  SHFProject::Application.load_seed
end

Then(/^(\d+) "([^"]*)" records should be created$/) do |number_of_records, models|
  model_klass = ActiveSupport::Inflector.singularize(models)
  expect((eval "#{model_klass}").all.size).to eq(number_of_records.to_i)
end
