require 'redmine'
require 'dispatcher'

Dispatcher.to_prepare :redmine_custom do 
  require_dependency 'mailer'
  require_dependency 'redmine_custom/hooks'

  unless Mailer.included_modules.include? RedmineCustom::MailerPatch
    Mailer.send(:include, RedmineCustom::MailerPatch)
  end
end

Redmine::Plugin.register :redmine_custom do
  name 'Custom Redmine enhancements'
  author 'Author name'
  description 'This plugin implements a nuber of custom enhancements used with our Redmine installation'
  version '0.0.3'
  url 'http://github.com/kulesa/redmine_custom'
  author_url 'http://github.com/kulesa'
  
  menu :top_menu, :all_tasks, {:controller => 'issues', :action => 'index' }, :caption => 'All tasks', :after => :projects
  menu :top_menu, :gantt, {:controller => 'issues/gantt', :action => 'index' }, :caption => 'Gantt', :after => :all_tasks
  menu :top_menu, :files, {:controller => 'files', :action => 'index' }, :caption => 'Files', :after => :gantt
  menu :top_menu, :calendar, {:controller => 'issues/calendar', :action => 'index' }, :caption => 'Calendar', :after => :files
  menu :top_menu, :buzz, {:controller => 'activity', :action => 'index' }, :caption => 'Buzz', :after => :calendar
end
