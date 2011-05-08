module RedmineCustom
  class StaleObject
    include Redmine::I18n
    include ERB::Util
    attr_accessor :attributes
    attr_accessor :changes
    
    def initialize(stale_object)
      raise ArgumentError.new("Call with an ActiveRecord object") unless stale_object.respond_to?(:attributes)
      @attributes = stale_object.attributes.dup
      puts ">>>> Stale object reporting: #{@attributes}"
    end
    
    def differences(fresh_object, options = { })
      changes = self.changes(fresh_object)
      
      error_messages = []
      unless changes.empty?
        changes.each do |key,value|
          if key.match(/(.*)(_id)$/)
            association = fresh_object.class.reflect_on_association($1.to_sym)
            if association
              field = 'field_' + key.sub($2,'')
              if value.nil?
                data_value = l(:label_none)
              else
                data_value = association.klass.find(value)
              end
            end
          end
          field ||= 'field_' + key
          data_value ||= value || l(:label_none)
          error_messages << "#{l(field.to_sym)} changed to #{html_escape(data_value)};"
        end
      end
      
      return error_messages
    end

    def changes(fresh_object)
      @changes ||= @attributes.diff(fresh_object.attributes).except('lock_version') || { }
    end
  end
end
