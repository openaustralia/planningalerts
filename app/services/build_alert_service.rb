# frozen_string_literal: true

class BuildAlertService
  attr_reader :alert

  def initialize(alert)
    @alert = alert
  end

  def parse
    alert.geocode_from_address

    preexisting_matching_alert ? parse_for_preexisting_alert_states : alert
  end

  private

  def parse_for_preexisting_alert_states
    if preexisting_alert_is_confirmed_but_unsubscribed?
      alert
    elsif preexisting_alert_is_confirmed_and_subscribed?
      send_notice_to_existing_active_alert_owner_and_return
    elsif preexisting_alert_is_unconfirmed?
      resend_original_confirmation_email_and_return
    end
  end

  def preexisting_alert_is_confirmed_but_unsubscribed?
    preexisting_matching_alert.confirmed? && preexisting_matching_alert.unsubscribed?
  end

  def preexisting_alert_is_confirmed_and_subscribed?
    preexisting_matching_alert.confirmed? && !preexisting_matching_alert.unsubscribed?
  end

  def preexisting_alert_is_unconfirmed?
    !preexisting_matching_alert.confirmed?
  end

  def preexisting_matching_alert
    Alert.find_by(email: alert.email, address: alert.address)
  end

  def send_notice_to_existing_active_alert_owner_and_return
    AlertNotifier.new_signup_attempt_notice(
      preexisting_matching_alert
    ).deliver_later

    nil
  end

  def resend_original_confirmation_email_and_return
    preexisting_matching_alert.send_confirmation_email

    nil
  end
end
