# typed: strict
# frozen_string_literal: true

class BuildAlertService < ApplicationService
  extend T::Sig

  sig { returns(Alert) }
  attr_reader :alert

  sig { params(email: String, address: String, radius_meters: Integer).void }
  def initialize(email:, address:, radius_meters:)
    @alert = T.let(
      Alert.new(
        email: email,
        address: address,
        radius_meters: radius_meters
      ),
      Alert
    )
  end

  sig { returns(T.nilable(Alert)) }
  def call
    # Ensures the address is normalised into a consistent form
    alert.geocode_from_address

    a = preexisting_alert
    if !a
      alert
    else
      if a.confirmed?
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
  sig { returns(T.nilable(Alert)) }
  def preexisting_alert
    Alert.find_by(
      email: alert.email,
      address: alert.address,
      unsubscribed: false
    )
  end

  sig { void }
  def send_notice_to_existing_active_alert_owner
    AlertMailer.new_signup_attempt_notice(
      preexisting_alert
    ).deliver_later
  end

  sig { void }
  def resend_original_confirmation_email
    T.must(preexisting_alert).send_confirmation_email
  end
end
