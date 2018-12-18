# frozen_string_literal: true

class BuildAlertService < ApplicationService
  attr_reader :alert

  def initialize(email:, address:, radius_meters:)
    @alert = Alert.new(
      email: email,
      address: address,
      radius_meters: radius_meters
    )
  end

  def call
    # Ensures the address is normalised into a consistent form
    alert.geocode_from_address

    if !preexisting_alert
      alert
    else
      if preexisting_alert.confirmed?
        send_notice_to_existing_active_alert_owner
      else
        resend_original_confirmation_email
      end
      nil
    end
  end

  private

  # Matching alerts that have been made before including those that haven't
  # been confirmed yet
  def preexisting_alert
    Alert.find_by(
      email: alert.email,
      address: alert.address,
      unsubscribed: false
    )
  end

  def send_notice_to_existing_active_alert_owner
    AlertNotifier.new_signup_attempt_notice(
      preexisting_alert
    ).deliver_later
  end

  def resend_original_confirmation_email
    preexisting_alert.send_confirmation_email
  end
end
