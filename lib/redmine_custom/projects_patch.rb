module RedmineCustom
  module ProjectsPatch
    def self.included(base)
     base.send(:include, InstanceMethods) 

     base.class_eval do 
       alias_method_chain :index, :all_visible
     end
    end

    module InstanceMethods
      # Include all projects, not only visible to the user
      def index_with_all_visible
        respond_to do |format|
          format.html { 
            if User.current.logged?
              @projects = Project.find(:all, :order => 'lft') 
            else
              @projects = Project.visible.find(:all, :order => 'lft') 
            end
          }
          format.api  {
            @offset, @limit = api_offset_and_limit
            @project_count = Project.visible.count
            @projects = Project.visible.all(:offset => @offset, :limit => @limit, :order => 'lft')
          }
          format.atom {
            projects = Project.visible.find(:all, :order => 'created_on DESC',
                                                  :limit => Setting.feeds_limit.to_i)
            render_feed(projects, :title => "#{Setting.app_title}: #{l(:label_project_latest)}")
          }
        end
 
      end
    end
  end
end

