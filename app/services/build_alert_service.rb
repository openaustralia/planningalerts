# typed: strict
# frozen_string_literal: true

class BuildAlertService
  extend T::Sig

  sig { params(email: String, address: String, radius_meters: Integer).returns(T.nilable(Alert)) }
  def self.call(email:, address:, radius_meters:)
    new(email: email, address: address, radius_meters: radius_meters).call
  end

  sig { params(email: String, address: String, radius_meters: Integer).void }
  def initialize(email:, address:, radius_meters:)
    @email = email
    @address = address
    @radius_meters = radius_meters
  end

  sig { returns(T.nilable(Alert)) }
  def call
    # Create an unconfirmed user without a password if one doesn't already exist matching the email address
    user = User.find_by(email: @email)
    if user.nil?
      # from_alert_or_comment says that this user was created "from" an alert rather than a user
      # registering an account in the "normal" way
      user = User.new(email: @email, from_alert_or_comment: true)
      # Otherwise it would send out a confirmation email on saving the record
      user.skip_confirmation_notification!
      user.temporarily_allow_empty_password!
      # We're not saving the new user record until the alert has validated
    end

    alert = Alert.new(
      user: user,
      address: @address,
      radius_meters: @radius_meters
    )

    # Ensures the address is normalised into a consistent form
    alert.geocode_from_address

    a = preexisting_alert(alert)
    if a
      if a.confirmed?
        send_notice_to_existing_active_alert_owner(alert)
      else
        resend_original_confirmation_email(alert)
      end
      nil
    else
      alert
    end
  end

  private

  # Matching alerts that have been made before including those that haven't
  # been confirmed yet
  sig { params(alert: Alert).returns(T.nilable(Alert)) }
  def preexisting_alert(alert)
    user = User.find_by(email: alert.email)
    return nil if user.nil?

    Alert.find_by(
      user: user,
      address: alert.address,
      unsubscribed: false
    )
  end

  sig { params(alert: Alert).void }
  def send_notice_to_existing_active_alert_owner(alert)
    AlertMailer.new_signup_attempt_notice(
      T.must(preexisting_alert(alert))
    ).deliver_later
  end

  sig { params(alert: Alert).void }
  def resend_original_confirmation_email(alert)
    T.must(preexisting_alert(alert)).send_confirmation_email
  end
end
