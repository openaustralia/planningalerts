# frozen_string_literal: true

require "spec_helper"

# Regression spec for https://github.com/openaustralia/planningalerts/issues/2255
#
# The admin policies were moved into the Admin namespace (Admin::TestEmailsPolicy etc.)
# but a handful of hand-written `authorize` calls in admin controllers kept looking up the
# old top-level policy class, which no longer exists. Pundit then raised NotDefinedError,
# which surfaced as a 500.
describe "Admin sends a test email" do
  let(:recipient) { "recipient@example.org" }

  def sign_in(user)
    post "https://www.planningalerts.org.au/users/sign_in",
         params: { user: { email: user.email, password: user.password } }
    follow_redirect!
  end

  context "when signed in as an admin" do
    before do
      admin = create(:confirmed_user)
      admin.add_role(:admin)
      sign_in(admin)
    end

    it "sends the email and redirects back to the form with a confirmation" do
      expect do
        post "https://www.planningalerts.org.au/admin/test_emails",
             params: { test_email: { email: recipient } }
      end.to change(ActionMailer::Base.deliveries, :count).by(1)

      expect(response).to redirect_to("https://www.planningalerts.org.au/admin/test_emails")
      expect(ActionMailer::Base.deliveries.last.to).to eq [recipient]

      follow_redirect!
      expect(response.body).to include("Test email sent to #{recipient}")
    end
  end

  context "when signed in as an api_editor, who can use the admin panel but not send test emails" do
    before do
      editor = create(:confirmed_user)
      editor.add_role(:api_editor)
      sign_in(editor)
    end

    it "does not send the email and does not 500" do
      expect do
        post "https://www.planningalerts.org.au/admin/test_emails",
             params: { test_email: { email: recipient } }
      end.not_to change(ActionMailer::Base.deliveries, :count)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
