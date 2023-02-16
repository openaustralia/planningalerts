# frozen_string_literal: true

# You can preview the mails by browsing to http://localhost:3000/rails/mailers

require "factory_bot_rails"

class AlertsPreview < ActionMailer::Preview
  def alert
    alert = Alert.new(
      lat: -33.902723,
      lng: 151.163362,
      radius_meters: 1000,
      user: User.new(email: "mary@example.com", password: "foo"),
      address: "1 Illawarra Road Marrickville 2204",
      confirm_id: "1234",
      id: 1
    )
    application = Application.new(
      id: 1,
      address: "50 Illawarra Road Marrickville 2204",
      lat: -33.904130,
      lng: 151.161630,
      description: "Something is happening here"
    )
    comment = Comment.new(
      application: Application.new(
        id: 2,
        description: "Erection of a bouncy castle",
        address: "20 Illawarra Road Marrickville 2204"
      ),
      text: "I really don't like inflatable things",
      name: "Martha"
    )

    AlertMailer.alert(alert:, applications: [application], comments: [comment])
  end

  def alert_account_requires_activation
    alert = Alert.new(
      lat: -33.902723,
      lng: 151.163362,
      radius_meters: 1000,
      user: User.new(email: "mary@example.com", password: ""),
      address: "1 Illawarra Road Marrickville 2204",
      confirm_id: "1234",
      id: 1
    )
    application = Application.new(
      id: 1,
      address: "50 Illawarra Road Marrickville 2204",
      lat: -33.904130,
      lng: 151.161630,
      description: "Something is happening here"
    )
    comment = Comment.new(
      application: Application.new(
        id: 2,
        description: "Erection of a bouncy castle",
        address: "20 Illawarra Road Marrickville 2204"
      ),
      text: "I really don't like inflatable things",
      name: "Martha"
    )

    AlertMailer.alert(alert:, applications: [application], comments: [comment])
  end
end
