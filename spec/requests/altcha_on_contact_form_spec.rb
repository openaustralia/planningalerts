# frozen_string_literal: true

require "spec_helper"

# The contact form is the one form that already had an anti-spam check, so
# ALTCHA and reCAPTCHA are alternatives here rather than both at once.
describe "ALTCHA on the contact form" do
  include Devise::Test::IntegrationHelpers

  before { stub_const("CreateAltchaChallengeService::COST", 100) }

  let(:params) do
    { contact_message: { name: "Jane Citizen", email: "jane@example.com", reason: "other", details: "Hello" } }
  end

  # Both flags on is the state in which the contact form switches to ALTCHA.
  def enforce!
    Flipper.enable(:altcha)
    Flipper.enable(:altcha_enforce)
  end

  context "when the altcha flags are off" do
    it "behaves exactly as before, with no ALTCHA anywhere" do
      get documentation_contact_path

      expect(response.body).not_to include("altcha-widget")
    end

    it "still accepts a message, since there are no reCAPTCHA credentials in test" do
      expect { post contact_messages_path, params: }.to change(ContactMessage, :count).by(1)
    end
  end

  # Monitor mode would mean showing two captchas at once to gather data, which
  # is a poor experience for no real gain. So the contact form stays on
  # reCAPTCHA until altcha_enforce is on, and is never left unprotected.
  context "when altcha is on but altcha_enforce is off" do
    before { Flipper.enable(:altcha) }

    it "does not show the widget yet" do
      get documentation_contact_path

      expect(response.body).not_to include("altcha-widget")
    end
  end

  context "when both altcha flags are on" do
    before { enforce! }

    it "shows the ALTCHA widget" do
      get documentation_contact_path

      expect(response.body).to include("altcha-widget")
    end

    it "no longer shows reCAPTCHA, so nobody sees two checks at once" do
      get documentation_contact_path

      expect(response.body).not_to include("g-recaptcha")
    end

    it "rejects a message with no answer" do
      expect { post contact_messages_path, params: }.not_to change(ContactMessage, :count)
    end

    it "explains why the message wasn't sent" do
      post(contact_messages_path, params:)

      expect(response.body).to include("Please reload the page and try again")
    end

    it "accepts a message that solved the challenge" do
      expect { post contact_messages_path, params: params.merge(altcha: solve_altcha_challenge) }
        .to change(ContactMessage, :count).by(1)
    end

    context "when somebody is signed in" do
      let(:user) { create(:confirmed_user) }

      before { sign_in user }

      it "asks them for nothing, the same as it does with reCAPTCHA" do
        expect { post contact_messages_path, params: }.to change(ContactMessage, :count).by(1)
      end

      it "doesn't show them the widget" do
        get documentation_contact_path

        expect(response.body).not_to include("altcha-widget")
      end
    end
  end
end
