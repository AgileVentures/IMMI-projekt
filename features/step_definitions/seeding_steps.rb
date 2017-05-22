
Given(/^There are no "([^"]*)" records in the db$/) do | models|
  model_klass = ActiveSupport::Inflector.singularize(models)
  eval "#{model_klass}.delete_all"
end

When(/^the system is seeded with initial data$/) do
  SHFProject::Application.load_tasks
  SHFProject::Application.load_seed
end
