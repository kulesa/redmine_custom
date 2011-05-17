module ApplicationHelper

  def self.included(base)
    base.class_eval do 
      alias_method_chain :authoring, :on
    end
  end

  # Adding date to authoring string, so it looks like 
  # Updated by Username about 7 days ago, on 15 May 2010 at 14:30
  def authoring_with_on(created, author, options={})
    time_label = options[:label] || :label_added_time_by
    time_label = :label_updated_time_by_on if time_label == :label_updated_time_by
    l(time_label, 
        :author => link_to_user(author), 
        :age => time_tag(created),
        :on => format_date(created), 
        :at => format_time(created, false))
  end
end

