require 'redmine'

Redmine::Plugin.register :redmine_rejected_issues do
  name 'Rejected Issues'
  author 'Roman Shipiev'
  description 'Block for my/page and rake-task for mail delivery (IssueStatus = "Reject")'
  version '0.0.1'
  url 'https://bitbucket.org/rubynovich/redmine_rejected_issues'
  author_url 'http://roman.shipiev.me'

  settings :default => {
                       :issue_status => IssueStatus.last(:conditions => {:is_closed => false}).try(:id)
                     },
         :partial => 'rejected_issues/settings'
end

if Rails::VERSION::MAJOR < 3
  require 'dispatcher'
  object_to_prepare = Dispatcher
else
  object_to_prepare = Rails.configuration
end

object_to_prepare.to_prepare do
  [:mailer].each do |cl|
    require "rejected_issues_#{cl}_patch"
  end

  [
    [Mailer, RejectedIssuesPlugin::MailerPatch]
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end
end
