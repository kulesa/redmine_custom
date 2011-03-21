module RedmineCustom
  module IssueWatchablePatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable

        before_create :add_all_project_users_as_watchers 
      end
    end

    module InstanceMethods
      def add_all_project_users_as_watchers
       self.addable_watcher_users.each do |u|
         self.add_watcher(u)
       end
      end
    end
  end
end
