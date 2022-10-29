# typed: strict
# frozen_string_literal: true

class BuildAlertService
  extend T::Sig

  sig { params(user: User, address: String, radius_meters: Integer).returns(T.nilable(Alert)) }
  def self.call(user:, address:, radius_meters:)
    new(user: user, address: address, radius_meters: radius_meters).call
  end

  sig { params(user: User, address: String, radius_meters: Integer).void }
  def initialize(user:, address:, radius_meters:)
    @email = T.let(user.email, String)
    @user = user
    @address = address
    @radius_meters = radius_meters
  end

  sig { returns(T.nilable(Alert)) }
  def call
    alert = Alert.new(
      email: @email,
      user: @user,
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
    Alert.find_by(
      email: alert.email,
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
