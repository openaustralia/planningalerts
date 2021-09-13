# typed: strict
# frozen_string_literal: true

# Sends out a bunch of email alerts and
# records the batch being sent out and updates the global statistics
class ProcessAlertAndRecordStatsService < ApplicationService
  extend T::Sig

  sig { params(alert_id: Integer).void }
  def self.call(alert_id:)
    new(alert_id: alert_id).call
  end

  sig { params(alert_id: Integer).void }
  def initialize(alert_id:)
    @alert_id = alert_id
  end

  sig { void }
  def call
    alert = Alert.find(alert_id)
    no_emails, no_applications, no_comments = ProcessAlertService.call(alert: alert)

    # Don't need to do anything further if no email was sent
    return if no_emails.zero?

    # Update statistics
    # TODO: Figure out the impact on caching updating this so regularly now
    Stat.increment_emails_sent(no_emails)
    Stat.increment_applications_sent(no_applications)
    # TODO: Rename EmailBatch as we're not using batches anymore
    EmailBatch.create!(
      no_emails: no_emails,
      no_applications: no_applications,
      no_comments: no_comments,
      # TODO: Remove the no_replies field from EmailBatch
      no_replies: 0
    )
  end

  private

  sig { returns(Integer) }
  attr_reader :alert_id
end
