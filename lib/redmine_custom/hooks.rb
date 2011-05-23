module RedmineCustom
  class Hooks < Redmine::Hook::ViewListener
    include Redmine::I18n
    
    render_on :view_issues_edit_notes_bottom, :partial => 'attachments/upload_conflict'

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

  class ViewLayoutsBaseBodyBottomHook < Redmine::Hook::ViewListener
    def view_layouts_base_body_bottom(context={})
      if context[:controller] && context[:controller].is_a?(IssuesController)
        return javascript_include_tag('raphael-min.js', :plugin => 'redmine_better_gantt_chart') + 
          javascript_include_tag('http://nata.isclist.com/js_lib/mindmap.js')
      else
        return ''
      end
    end
  end
end

