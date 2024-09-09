# typed: strict
# frozen_string_literal: true

module Admin
  class TestEmailsController < Admin::ApplicationController
    extend T::Sig

    sig { void }
    def index; end

    sig { void }
    def create
      authorize :test_emails
      params_test_email = T.cast(params[:test_email], ActionController::Parameters)

      # Ugh. Copied and pasted from email preview in spec/
      alert = Alert.new(
        lat: -33.902723,
        lng: 151.163362,
        radius_meters: 200,
        user: User.new(email: params_test_email[:email], password: "foo"),
        address: "89 Bridge Rd, Richmond VIC 3121",
        confirm_id: "1234",
        id: 1
      )
      application1 = Application.new(
        id: 1,
        address: "6 Kahibah Road, Umina Beach, NSW",
        lat: -33.90413,
        lng: 151.16163,
        description: "S4.55 to Modify Approved Dwelling and Garage including Deletion of Clerestory, Addition of Laminated Beam, " \
                     "Relocation of Laundry, Deletion of Stairs and Expansion of Workshop"
      )
      application2 = Application.new(
        id: 2,
        address: "6 Kahibah Road, Umina Beach, NSW",
        lat: -33.90413,
        lng: 151.16163,
        description: "Building subdivision"
      )
      comment = Comment.new(
        application: Application.new(
          id: 2,
          address: "6 Kahibah Road, Umina Beach, NSW",
          lat: -33.90413,
          lng: 151.16163,
          description: "S4.55 to Modify Approved Dwelling and Garage including Deletion of Clerestory, Addition of Laminated Beam, " \
                       "Relocation of Laundry, Deletion of Stairs and Expansion of Workshop"
        ),
        text: "It has recently come to my attention that a planning application has been submitted" \
              "for 813 Hight Street, Reservoir.\n\n" \
              "My concern is with the application for ground floor shops and nine (9) dwellings," \
              "above, with a reduction in the car parking requirements.\n\n" \
              "Currently, there are already parking issues in the area, with insufficient parking" \
              "bays available. Residents of Wild Street and Henry Street are constantly complaining" \
              "about cars parked on \"their\" street. We often find abusive notes left on vehicles," \
              "harassment of staff when in the street, and stupid acts of vandalism. We are a" \
              "business on High Street and staff already have difficulty finding parking as it" \
              "is. It appears that the council is not concerned for its local businesses or residents" \
              "and allowing a new building with reduced parking is irresponsible and inconsiderate." \
              "I understand that the council and developers want to make as much money as possible but" \
              "it is extremely unfair to cause such distress and inconvenience to everyone else." \
              "I strongly oppose such a development and would like further information as to how to" \
              "make this a formal objection.\n\n" \
              "Regards\n" \
              "Louise",
        name: "Martha"
      )

      AlertMailer.alert(alert:, applications: [application1, application2], comments: [comment]).deliver_now!
    end
  end
end
