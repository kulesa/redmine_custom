module RedmineCustom
  module IssueMandatoryAttrsPatch
    def self.included(base) # :nodoc:
      base.class_eval do
        validates_presence_of :due_date
      end
    end
  end
end
