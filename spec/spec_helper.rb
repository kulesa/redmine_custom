# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"

# Allows loading of an environment config based on the environment
redmine_root = ENV["REDMINE_ROOT"] || File.dirname(__FILE__) + "/../../../.."
require File.expand_path(redmine_root + "/config/environment")
require 'spec'
require 'spec/rails'
require 'factory_girl'
require 'database_cleaner'

require File.expand_path(File.dirname(__FILE__) + '/factories.rb')

Spec::Runner.configure do |config|
  DatabaseCleaner.strategy = :deletion
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  config.before(:suite) do 
    DatabaseCleaner.strategy = :deletion
  end

  config.after(:suite) do 
    DatabaseCleaner.clean
  end
end

# require the entire app if we're running under coverage testing,
# so we measure 0% covered files in the report
#
# http://www.pervasivecode.com/blog/2008/05/16/making-rcov-measure-your-whole-rails-app-even-if-tests-miss-entire-source-files/
if defined?(Rcov)
  all_app_files = Dir.glob('{app,lib}/**/*.rb')
  all_app_files.each{|rb| require rb}
end

