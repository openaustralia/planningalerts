# frozen_string_literal: true

# You can preview the mails by browsing to http://localhost:3000/rails/mailers

class AlertMailerPreview < ActionMailer::Preview
  def alert
    # Not using Factory here because it seems to be causing problems
    # with the module reloading
    alert = Alert.create!(
      lat: -33.902723,
      lng: 151.163362,
      radius_meters: 1000,
      email: "mary@example.com",
      address: "1 Illawarra Road Marrickville 2204"
    )
    # This needs to have an application and a comment loaded for this to work
    applications = [Application.first]
    comments = [Comment.first]
    mail = AlertMailer.alert(alert, applications, comments)
    alert.destroy
    mail
  end
end
