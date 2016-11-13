unless Rails.env.production?
  require 'rspec/core/rake_task'
  require 'cucumber/rake/task'
  require 'coveralls/rake/task'

  Coveralls::RakeTask.new

  namespace :ci do
    desc 'Run Rspec and Cucumber then push coverage report to coveralls'
    task tests: [:spec, :cucumber, 'coveralls:push']
  end
end