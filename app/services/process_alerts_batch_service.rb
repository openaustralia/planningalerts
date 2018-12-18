# frozen_string_literal: true

class ProcessAlertsBatchService
  def initialize(alert_ids:)
    @alert_ids = alert_ids
  end

  # TODO: Also include no_replies in stats and return
  def call
    # Only send alerts to confirmed users
    total_no_emails = 0
    total_no_applications = 0
    total_no_comments = 0
    Alert.find(alert_ids).each do |alert|
      no_applications, no_comments = ProcessAlertService.call(alert: alert)
      next if no_applications.zero? && no_comments.zero?

      total_no_applications += no_applications
      total_no_comments += no_comments
      total_no_emails += 1
    end

    # Update statistics. Updating the Stat at the end of each mail run has the advantage of not continiously invalidating
    # page caches during mail runs.
    Stat.emails_sent += total_no_emails
    Stat.applications_sent += total_no_applications
    EmailBatch.create!(no_emails: total_no_emails, no_applications: total_no_applications,
                       no_comments: total_no_comments)
    [total_no_emails, total_no_applications, total_no_comments]
  end

  private

  attr_reader :alert_ids
end
