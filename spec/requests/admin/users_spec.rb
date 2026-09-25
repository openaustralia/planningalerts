# frozen_string_literal: true

require "spec_helper"

# Regression spec for https://github.com/openaustralia/planningalerts/issues/2255
#
# `authorize User, :index?` in Admin::UsersController#export_confirmed_emails looked up a
# top-level UserPolicy, which was removed when the admin policies moved into the Admin
# namespace. Pundit raised NotDefinedError, which surfaced as a 500.
describe "Admin exports confirmed email addresses" do
  def sign_in(user)
    post "https://www.planningalerts.org.au/users/sign_in",
         params: { user: { email: user.email, password: user.password } }
    follow_redirect!
  end

  context "when signed in as an admin" do
    before do
      admin = create(:confirmed_user, email: "admin@example.org")
      admin.add_role(:admin)
      create(:confirmed_user, email: "jane@example.org")
      create(:user, email: "unconfirmed@example.org")
      sign_in(admin)
    end

    it "downloads the confirmed addresses as a text file" do
      get "https://www.planningalerts.org.au/admin/users/export_confirmed_emails"

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Disposition"]).to include("emails.txt")
      expect(response.body.split("\n")).to contain_exactly("admin@example.org", "jane@example.org")
    end
  end

  context "when signed in as a scraper_editor, who can use the admin panel but not see people" do
    before do
      editor = create(:confirmed_user)
      editor.add_role(:scraper_editor)
      sign_in(editor)
    end

    it "is refused without a 500" do
      get "https://www.planningalerts.org.au/admin/users/export_confirmed_emails"

      expect(response).to have_http_status(:forbidden)
    end
  end
end
