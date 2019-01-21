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

    # Update statistics
    # TODO: Deal with concurrency issues with the way the stats are beign updated
    # TODO: Figure out the impact on caching updating this so regularly now
    Stat.emails_sent += no_emails
    Stat.applications_sent += no_applications
    # TODO: Rename EmailBatch as we're not using batches anymore
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
