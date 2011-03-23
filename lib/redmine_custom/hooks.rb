module RedmineCustom
  class Hooks < Redmine::Hook::ViewListener
    include Redmine::I18n
    
    def helper_issues_show_detail_after_setting(context = {})
      if context[:detail].property == 'attachment'
        a = Attachment.find_by_id(context[:detail].prop_key)
        # TODO: change to link_to
        # AGRHHHH, how to get full path in mailer??? DUNNO
        value = "#{h(a.filename)} (#{url_for(:controller => 'attachments', :action => 'download', :id => a.id, :filename => a.download_name, 
                  :only_path => false, :host => Mailer.default_url_options[:host])})" unless a.nil?
        context[:detail].value = value
      end
      ''
    end
  end
end

