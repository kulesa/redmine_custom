require 'redmine'
require 'dispatcher'

Dispatcher.to_prepare :redmine_custom do 
  require_dependency 'mailer'
  require_dependency 'redmine_custom/hooks'

  unless Mailer.included_modules.include? RedmineCustom::MailerPatch
    Mailer.send(:include, RedmineCustom::MailerPatch)
  end

  unless BoardsController.included_modules.include? RedmineCustom::BoardsPatch
    BoardsController.send(:include, RedmineCustom::BoardsPatch)
  end

  unless ProjectsController.included_modules.include? RedmineCustom::ProjectsControllerPatch
    ProjectsController.send(:include, RedmineCustom::ProjectsControllerPatch)
  end

  unless Project.included_modules.include? RedmineCustom::ProjectPatch
    Project.send(:include, RedmineCustom::ProjectPatch)
  end
end

Redmine::Plugin.register :redmine_custom do
  name 'Custom Redmine enhancements'
  author 'Author name'
  description 'This plugin implements a nuber of custom enhancements used with our Redmine installation'
  version '0.1.0'
  url 'http://github.com/kulesa/redmine_custom'
  author_url 'http://github.com/kulesa'
  
  menu :top_menu, :all_tasks, {:controller => 'issues', :action => 'index' }, :caption => :custom_all_issues_title, :after => :projects
  menu :top_menu, :gantt, {:controller => 'issues/gantt', :action => 'index' }, :caption => :project_module_gantt, :after => :all_tasks
  menu :top_menu, :files, {:controller => 'files', :action => 'index' }, :caption => :project_module_files, :after => :gantt
  menu :top_menu, :calendar, {:controller => 'issues/calendar', :action => 'index' }, :caption => :project_module_calendar, :after => :files
  menu :top_menu, :boards, {:controller => 'boards', :action => 'index' }, :caption => :label_board_plural, :after => :calendar
  menu :top_menu, :buzz, {:controller => 'activity', :action => 'index' }, :caption => :custom_activity_module_title, :after => :boards
end
