module ProjectsHelper

  def self.included(base)
    base.class_eval do 
      alias_method_chain :render_project_hierarchy, :wraps
    end
  end
  
  def render_project_hierarchy_with_wraps(projects)
    s = ''
    if projects.any?
      ancestors = []
      original_project = @project
      projects.each do |project|
        # set the project environment to please macros.
        @project = project
        if (ancestors.empty? || project.is_descendant_of?(ancestors.last))
          unless ancestors.last.nil?
            ul_id = " id='sub_#{ancestors.last.id}' style='display:none'" 
          end
          s << "<ul class='projects #{ ancestors.empty? ? 'root' : nil}'#{ul_id}>\n"
        else
          ancestors.pop
          s << "</li>"
          while (ancestors.any? && !project.is_descendant_of?(ancestors.last)) 
            ancestors.pop
            s << "</ul></li>\n"
          end
        end
        classes = (ancestors.empty? ? 'root' : 'child')
        if !project.descendants.empty?
          toggle = "<a href='#' onclick='$(\"sub_#{project.id}\").toggle();'>[+]</a>" 
        else
          toggle = ""
        end
        s << "<li class='#{classes}'><div class='#{classes}'>" +
               toggle +
               link_to_project(project, {}, :class => "project #{User.current.member_of?(project) ? 'my-project' : nil}")
        s << "<div class='wiki description'>#{textilizable(project.short_description, :project => project)}</div>" unless project.description.blank?
        s << "</div>\n"
        ancestors << project
      end
      s << ("</li></ul>\n" * ancestors.size)
      @project = original_project
    end
    s
  end
  
end

