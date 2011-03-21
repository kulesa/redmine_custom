module QueriesHelper

  def self.included(base)
    base.class_eval do
      alias_method_chain :column_content, :nested_projects
    end
  end


  # Generates extended project info in 'Project' column of issues list.
  def column_content_with_nested_projects(column, issue)
    value = column.value(issue)
    
    case value.class.name
    when 'Project'
      project = issue.project
      b = []
      ancestors = (project.root? ? [] : project.ancestors.visible)
      if ancestors.any?
        root = ancestors.shift
        b << link_to_project(root, {:jump => current_menu_item}, :class => 'root')
        if ancestors.size > 1
          b << '&#8230;'
          ancestors = ancestors[-1, 1]
        end
        b += ancestors.collect {|p| link_to_project(p, {:jump => current_menu_item}, :class => 'ancestor') }
      end
      b << link_to_project(project, {:jump => current_menu_item}, :class => 'ancestor') 
      b.join(' &#187; ')
 
    else
      column_content_without_nested_projects(column, issue)
    end
  end
end
