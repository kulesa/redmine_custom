module RedmineCustom
  module ProjectPatch
    def self.included(base)
     base.send(:include, InstanceMethods) 

     base.class_eval do 
       # Returns visible projects and their ancestors
       def self.visible_with_ancestors(options = {})
         visible_projects = Project.visible
         visible_projects = (visible_projects + visible_projects.map(&:ancestors).flatten).uniq
         Project.find(:all, options).select {|p| visible_projects.include?(p) }
       end
     end
    end

    module InstanceMethods
    end
  end
end

