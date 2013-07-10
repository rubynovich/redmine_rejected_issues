desc <<-END_DESC
Send mails about rejected issues.

Available options:
  * cc       => send a copy of each message to this address (no copy per default)
Example:
  rake redmine:send_solved_issues cc=admin@example.net RAILS_ENV="production"
END_DESC

namespace :redmine do
  task :send_rejected_issues => :environment do
    options = {}
    options[:cc] = ENV['cc'] if ENV['cc']
    Mailer.rejected_issues(options)
  end
end
