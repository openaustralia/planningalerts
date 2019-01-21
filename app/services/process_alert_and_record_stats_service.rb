# frozen_string_literal: true

# Sends out a bunch of email alerts and
# records the batch being sent out and updates the global statistics
class ProcessAlertAndRecordStatsService < ApplicationService
  def initialize(alert_id:)
    @alert_id = alert_id
  end

  # TODO: Also include no_replies in stats
  def call
    alert = Alert.find(alert_id)
    no_emails, no_applications, no_comments, no_replies = ProcessAlertService.call(alert: alert)

    # Update statistics. Updating the Stat at the end of each mail run has the advantage of not continiously invalidating
    # page caches during mail runs.
    Stat.emails_sent += no_emails
    Stat.applications_sent += no_applications
    EmailBatch.create!(
      no_emails: no_emails,
      no_applications: no_applications,
      no_comments: no_comments,
      no_replies: no_replies
    )
  end

  private

  attr_reader :alert_id
end
