class NewAlertParser
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
    if preexisting_matching_alert.confirmed?
      if preexisting_matching_alert.unsubscribed?
        alert
      else
        nil
      end
    else
      preexisting_matching_alert.send_confirmation_email

      nil
    end
  end

  def preexisting_matching_alert
    Alert.find_by(email: alert.email, address: alert.address)
  end
end
