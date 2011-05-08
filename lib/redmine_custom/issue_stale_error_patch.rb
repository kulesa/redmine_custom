module RedmineCustom
  module IssueStaleErrorPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :save_issue_with_child_records, :stale_object_handling
      end
    end
  
    module InstanceMethods

      def save_issue_with_child_records_with_stale_object_handling(params, existing_time_entry=nil)
        Issue.transaction do
          if params[:time_entry] && params[:time_entry][:hours].present? && User.current.allowed_to?(:log_time, project)
            @time_entry = existing_time_entry || TimeEntry.new
            @time_entry.project = project
            @time_entry.issue = self
            @time_entry.user = User.current
            @time_entry.spent_on = Date.today
            @time_entry.attributes = params[:time_entry]
            self.time_entries << @time_entry
          end
      
          if valid?
            attachments = Attachment.attach_files(self, params[:attachments])
      
            attachments[:files].each {|a| @current_journal.details << JournalDetail.new(:property => 'attachment', :prop_key => a.id, :value => a.filename)}
            Redmine::Hook.call_hook(:controller_issues_edit_before_save, { :params => params, :issue => self, :time_entry => @time_entry, :journal => @current_journal})
            begin
              if save
                Redmine::Hook.call_hook(:controller_issues_edit_after_save, { :params => params, :issue => self, :time_entry => @time_entry, :journal => @current_journal})
              else
                raise ActiveRecord::Rollback
              end
            rescue ActiveRecord::StaleObjectError
              attachments[:files].each(&:destroy)

              stale_object = RedmineCustom::StaleObject.new(Issue.find(params[:id]))
              self.safe_attributes = params[:issue]
              self.lock_version += 1

              errors.add_to_base l(:notice_locking_conflict) # + stale_object.difference_messages(self)
              stale_object.differences(self).each { |msg| errors.add_to_base(msg) } 
              raise ActiveRecord::Rollback
            end
          end
        end
      end

    end
  end
end
