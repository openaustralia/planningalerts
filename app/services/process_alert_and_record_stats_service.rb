# typed: strict
# frozen_string_literal: true

# Sends out a bunch of email alerts and
# records the batch being sent out and updates the global statistics
class ProcessAlertAndRecordStatsService
  extend T::Sig
  include Skylight::Helpers

  sig { params(alert: Alert).void }
  def self.call(alert:)
    new(alert:).call
  end

  sig { params(alert: Alert).void }
  def initialize(alert:)
    @alert = alert
  end

  instrument_method
  sig { void }
  def call
    no_emails, no_applications, no_comments = ProcessAlertService.call(alert:)

    # Don't need to do anything further if no email was sent
    return if no_emails.zero?

    # Update statistics
    # TODO: Figure out the impact on caching updating this so regularly now
    Stat.increment_emails_sent(no_emails)
    Stat.increment_applications_sent(no_applications)
    # TODO: Rename EmailBatch as we're not using batches anymore
    EmailBatch.create!(
      no_emails:,
      no_applications:,
      no_comments:
    )
  end

  private

  sig { returns(Alert) }
  attr_reader :alert
end
