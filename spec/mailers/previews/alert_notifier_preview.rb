class AlertNotifierPreview < ActionMailer::Preview
  def alert
    # Not using Factory here because it seems to be causing problems
    # with the module reloading
    alert = Alert.create!(
      lat: 0,
      lng: 0,
      radius_meters: 1000,
      email: "mary@example.com",
      address: "1 Illawarra Road Marrickville 2204"
    )
    mail = AlertNotifier.alert("default", alert, [Application.first])
    alert.destroy
    mail
  end
end
