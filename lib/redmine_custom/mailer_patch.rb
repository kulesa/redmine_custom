module RedmineCustom
  module MailerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      # Replace standard methods with our own custom
      base.class_eval do
        alias_method_chain :issue_add, :details
        alias_method_chain :issue_edit, :details
        alias_method_chain :attachments_added, :details
      end
    end
  end

  module InstanceMethods
    # Builds a tmail object used to email recipients of the added issue.
    #
    # Example:
    #   issue_add(issue) => tmail object
    #   Mailer.deliver_issue_add(issue) => sends an email to issue recipients
    # --------------------
    # CUSTOM: mail subject includes full project path
    def issue_add_with_details(issue)
      redmine_headers 'Project' => issue.project.identifier,
                      'Issue-Id' => issue.id,
                      'Issue-Author' => issue.author.login
      redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
      message_id issue
      recipients issue.recipients
      cc(issue.watcher_recipients - @recipients)
      subject "[#{full_project_path(issue.project)} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}"
      body :issue => issue,
           :issue_url => url_for(:controller => 'issues', :action => 'show', :id => issue)
      render_multipart('issue_add', body)
    end

    # Builds a tmail object used to email recipients of the edited issue.
    #
    # Example:
    #   issue_edit(journal) => tmail object
    #   Mailer.deliver_issue_edit(journal) => sends an email to issue recipients
    # --------------------
    # CUSTOM: mail subject includes full project path
    def issue_edit_with_details(journal)
      issue = journal.journalized.reload
      redmine_headers 'Project' => issue.project.identifier,
                      'Issue-Id' => issue.id,
                      'Issue-Author' => issue.author.login
      redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
      message_id journal
      references issue
      @author = journal.user
      recipients issue.recipients
      # Watchers in cc
      cc(issue.watcher_recipients - @recipients)
      s = "[#{full_project_path(issue.project)} - #{issue.tracker.name} ##{issue.id}] "
      s << "(#{issue.status.name}) " if journal.new_value_for('status_id')
      s << issue.subject
      subject s
      body :issue => issue,
           :journal => journal,
           :issue_url => url_for(:controller => 'issues', :action => 'show', :id => issue)

      render_multipart('issue_edit', body)
    end

    # Builds a tmail object used to email recipients of a project when an attachements are added.
    #
    # Example:
    #   attachments_added(attachments) => tmail object
    #   Mailer.deliver_attachments_added(attachments) => sends an email to the project's recipients
    # --------------------
    # CUSTOM: mail subject includes full project path
    def attachments_added_with_details(attachments)
      container = attachments.first.container
      added_to = ''
      added_to_url = ''
      case container.class.name
      when 'Project'
        added_to_url = url_for(:controller => 'projects', :action => 'list_files', :id => container)
        added_to = "#{l(:label_project)}: #{container}"
        recipients container.project.notified_users.select {|user| user.allowed_to?(:view_files, container.project)}.collect  {|u| u.mail}
      when 'Version'
        added_to_url = url_for(:controller => 'projects', :action => 'list_files', :id => container.project_id)
        added_to = "#{l(:label_version)}: #{container.name}"
        recipients container.project.notified_users.select {|user| user.allowed_to?(:view_files, container.project)}.collect  {|u| u.mail}
      when 'Document'
        added_to_url = url_for(:controller => 'documents', :action => 'show', :id => container.id)
        added_to = "#{l(:label_document)}: #{container.title}"
        recipients container.recipients
      end
      redmine_headers 'Project' => container.project.identifier
      subject "[#{full_project_path(container.project)}] #{l(:label_attachment_new)}"
      body :attachments => attachments,
           :added_to => added_to,
           :added_to_url => added_to_url
      render_multipart('attachments_added', body)
    end
    

    # Returns full project path like RootProject::ChildProject::GrandChildProject
    def full_project_path(project)
      b = []
      ancestors = (project.root? ? [] : project.ancestors.visible)
      if ancestors.any?
        root = ancestors.shift
        b << root.name
        if ancestors.size > 1
          b << '::'
          ancestors = ancestors[-1, 1]
        end
        b += ancestors.collect {|p| p.name}
      end
      b << project.name
      b.join('::')
    end
  end
end
