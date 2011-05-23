module RedmineCustom
  module AttachmentStaleErrorPatch
    def self.included(base) # :nodoc:
      base.extend ClassMethods

      base.class_eval do
        class << self
          alias_method_chain :attach_files, :stale_object_handling
        end
      end
    end
    
    module ClassMethods
      
      # Original method have been overridden to handle situations where an attachment
      # has been saved, but not associated with the journal (e.g. StaleObjectError)
      def attach_files_with_stale_object_handling(obj, attachments)
        attached = []
        if attachments && attachments.is_a?(Hash)
          attachments.each_value do |attachment|
            # Saved, but not associated with the journal attachment
            if attachment['id'] && (saved_attachment = Attachment.find_by_id(attachment['id']))
              if saved_attachment.container == obj
                attached << saved_attachment
              else                
                obj.unsaved_attachments ||= []
                obj.unsaved_attachments << saved_attachment
              end
            # New attachment
            elsif (file = attachment['file']) && file.size > 0
              a = Attachment.create(:container => obj, 
                                    :file => file,
                                    :description => attachment['description'].to_s.strip,
                                    :author => User.current)
              if a.new_record?
                obj.unsaved_attachments ||= []
                obj.unsaved_attachments << a
              else
                attached << a
              end
            else
              next
            end
          end
        end
        {:files => attached, :unsaved => obj.unsaved_attachments}
      end
    end
  end
end
