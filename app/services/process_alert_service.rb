# typed: strict
# frozen_string_literal: true

# Process email alert and send out an email if necessary.
# Returns number of applications and comments sent.
class ProcessAlertService
  extend T::Sig
  include Skylight::Helpers

  sig { params(alert: Alert).returns([Integer, Integer, Integer]) }
  def self.call(alert:)
    new(alert:).call
  end

  sig { params(alert: Alert).void }
  def initialize(alert:)
    @alert = alert
  end

  instrument_method
  sig { returns([Integer, Integer, Integer]) }
  def call
    applications = alert.recent_new_applications.to_a
    comments = alert.new_comments

    if !applications.empty? || !comments.empty?
      # offloading the actual sending of the email to another background job
      # since this depends on an external service which might be down.
      # Saves us from running the whole job again if it fails
      AlertMailer.alert(alert:, applications:, comments:).deliver_later
      alert.last_sent = Time.zone.now
      no_emails = 1
    else
      no_emails = 0
    end
    alert.last_processed = Time.zone.now
    alert.save!

    # Update the tallies on each application.
    applications.each do |application|
      # rubocop:disable Rails/SkipsModelValidations
      Application.increment_counter(:no_alerted, application.id)
      # rubocop:enable Rails/SkipsModelValidations
    end

    # Return number of emails, applications and comments sent
    [no_emails, applications.size, comments.size]
  end

  private

  sig { returns(Alert) }
  attr_reader :alert
end
