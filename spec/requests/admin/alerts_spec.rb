# frozen_string_literal: true

require "spec_helper"

# Regression spec for https://github.com/openaustralia/planningalerts/issues/2255
#
# `authorize(alert, :update?)` in Admin::AlertsController#unsubscribe resolved to the
# public AlertPolicy, whose update? only lets the alert's own user through. So an admin
# trying to unsubscribe somebody else's alert was refused. Admin::AlertPolicy is the one
# that applies here.
describe "Admin unsubscribes an alert" do
  let(:alert) { create(:alert, user: create(:confirmed_user, email: "jane@example.org")) }

  def sign_in(user)
    post "https://www.planningalerts.org.au/users/sign_in",
         params: { user: { email: user.email, password: user.password } }
    follow_redirect!
  end

  context "when signed in as an admin who does not own the alert" do
    before do
      admin = create(:confirmed_user)
      admin.add_role(:admin)
      sign_in(admin)
    end

    it "unsubscribes the alert" do
      post "https://www.planningalerts.org.au/admin/alerts/#{alert.id}/unsubscribe"

      expect(response).to redirect_to("https://www.planningalerts.org.au/admin/alerts/#{alert.id}")
      expect(alert.reload.unsubscribed).to be true

      follow_redirect!
      expect(response.body).to include("Alert unsubscribed")
    end
  end

  context "when signed in as an api_editor, who can use the admin panel but not manage alerts" do
    before do
      editor = create(:confirmed_user)
      editor.add_role(:api_editor)
      sign_in(editor)
    end

    it "leaves the alert alone without a 500" do
      post "https://www.planningalerts.org.au/admin/alerts/#{alert.id}/unsubscribe"

      expect(response).to have_http_status(:forbidden)
      expect(alert.reload.unsubscribed).to be false
    end
  end
end
