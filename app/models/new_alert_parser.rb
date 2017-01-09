class NewAlertParser
  attr_reader :alert

  def initialize(alert)
    @alert = alert
  end

  def parse
    alert.geocode_from_address

    if preexisting_matching_alert
      preexisting_alert = preexisting_matching_alert

      preexisting_alert.send_confirmation_email

      nil
    else
      alert
    end
  end

  private

  def preexisting_matching_alert
    Alert.find_by(email: alert.email, address: alert.address, confirmed: false)
  end
end
