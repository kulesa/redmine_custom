require 'redmine_plugin_support'

Dir[File.expand_path(File.dirname(__FILE__)) + "/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

RedminePluginSupport::Base.setup do |plugin|
  plugin.project_name = 'redmine_custom'
  plugin.default_task = [:spec]
  plugin.tasks = [:doc, :release, :clean, :test, :db, :spec]
  # TODO: gem not getting this automaticly
  plugin.redmine_root = File.expand_path(File.dirname(__FILE__) + '/../../../')
end
