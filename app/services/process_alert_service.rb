# frozen_string_literal: true

# Process email alert and send out an email if necessary.
# Returns number of applications and comments sent.
class ProcessAlertService < ApplicationService
  def initialize(alert:)
    @alert = alert
  end

  def call
    applications = alert.recent_applications
    comments = alert.new_comments
    replies = alert.new_replies

    if !applications.empty? || !comments.empty? || !replies.empty?
      AlertNotifier.alert(alert, applications, comments, replies).deliver_now
      alert.last_sent = Time.zone.now
      no_emails = 1
    else
      no_emails = 0
    end
    alert.last_processed = Time.zone.now
    alert.save!

    # Update the tallies on each application.
    applications.each do |application|
      application.increment(:no_alerted)
    end

    # Return number of emails, applications, comments and replies sent
    [no_emails, applications.size, comments.size, replies.size]
  end

  private

  attr_reader :alert
end
