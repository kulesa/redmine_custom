module RedmineCustom
  module IssuesControllerPatch
    def self.included(base)
     base.send(:include, InstanceMethods) 

     base.class_eval do 
       alias_method_chain :build_new_issue_from_params, :due_date
       alias_method_chain :update_issue_from_params, :due_date
     end
    end

    module InstanceMethods
      # Adds default value for due date
      def build_new_issue_from_params_with_due_date
        build_new_issue_from_params_without_due_date
        @issue.due_date ||= @issue.start_date + 1
      end

      # Adds default value for due date to issue updates
      def update_issue_from_params_with_due_date
        update_issue_from_params_without_due_date
        @issue.due_date ||= @issue.start_date + 1 
      end
    end
  end
end

