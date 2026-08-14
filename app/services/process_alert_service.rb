# typed: strict
# frozen_string_literal: true

# Process email alert and send out an email if necessary.
# Returns number of applications and comments sent.
class ProcessAlertService
  extend T::Sig

  sig { params(alert: Alert).returns([Integer, Integer, Integer]) }
  def self.call(alert:)
    new(alert:).call
  end

  sig { params(alert: Alert).void }
  def initialize(alert:)
    @alert = alert
  end

  sig { returns([Integer, Integer, Integer]) }
  def call
    # Newly registered users who have not confirmed their email address can potentially
    # have an alert setup but we don't want to send out emails until they have confirmed
    # their email address
    if T.must(alert.user).confirmed_at.nil?
      # Return number of emails, applications and comments sent
      # Note that we also intentionally don't want to update last_processed in this case
      return [0, 0, 0]
    end

    applications = alert.recent_new_applications.to_a
    comments = alert.new_comments
    send_email = !applications.empty? || !comments.empty?

    alert.last_sent = Time.zone.now if send_email
    alert.last_processed = Time.zone.now

    # Offloading the actual sending of the email to another background job
    # since this depends on an external service which might be down.
    # Saves us from running the whole job again if it fails.
    # We enqueue after saving so that a save that fails can't leave us having
    # sent an email without recording it, which would send it again next time.
    # Doing both inside a transaction means that if enqueueing fails the
    # last_sent update is rolled back, so a retry of this job re-processes the
    # same applications rather than silently skipping them.
    # requires_new is only needed so the rollback also happens when we're
    # already inside a transaction (e.g. in tests).
    Alert.transaction(requires_new: true) do
      alert.save!
      AlertMailer.alert(alert:, applications:, comments:).deliver_later if send_email
    end

    no_emails = send_email ? 1 : 0

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
