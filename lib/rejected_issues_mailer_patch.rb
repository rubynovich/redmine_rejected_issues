require_dependency 'mailer'

module RejectedIssuesPlugin
  module MailerPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
      end
    end

    module ClassMethods
      def rejected_issues(options={})
        mailcopy = options[:cc]
        status_id = Setting[:plugin_redmine_rejected_issues][:issue_status]
        issues = Issue.open.where(status_id: status_id)
        issues.select(&:author).map(&:author).uniq.map do |user|
          rejected_issues_mail(user, issues.where(author_id: user.id), mailcopy).deliver
        end
      end
    end

    module InstanceMethods
      def rejected_issues_mail(user, issues, mailcopy)
        set_language_if_valid user.language
        issues_count = issues.count
        subject = case issues_count
          when 1 then  l(:mail_subject_rejected_issues1, count: issues_count)
          when 2..4 then l(:mail_subject_rejected_issues2, count: issues_count)
          else l(:mail_subject_rejected_issues5, count: issues_count)
        end
        status_id = Setting[:plugin_redmine_rejected_issues][:issue_status]
        @status = IssueStatus.find(status_id)
        @rejected_issues = issues
        @firstname = user.firstname
        @lastname = user.lastname
        @issues_url = url_for(controller: 'issues', action: 'index', set_filter: 1, author_id: 'me', status_id: status_id, sort: 'priority:desc,updated_on:desc')
        mail(to: user.mail, cc: mailcopy, subject: subject) if user.mail.present? && issues_count.nonzero?
      end
    end
  end
end
