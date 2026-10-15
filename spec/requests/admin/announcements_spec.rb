# frozen_string_literal: true

require "spec_helper"

describe "Admin announcements" do
  include Devise::Test::IntegrationHelpers

  def sign_in_with_role(role)
    user = create(:confirmed_user)
    user.add_role(role)
    sign_in user
  end

  include ActiveSupport::Testing::TimeHelpers

  it "sends a logged-out visitor to log in" do
    get admin_announcements_path
    expect(response).to redirect_to(new_user_session_path)
  end

  it "refuses a user who is not an admin" do
    sign_in create(:confirmed_user)
    get admin_announcements_path
    expect(response).to have_http_status(:forbidden)
  end

  it "refuses an api_editor, who can use the admin panel but not manage announcements" do
    sign_in_with_role(:api_editor)
    get admin_announcements_path
    expect(response).to have_http_status(:forbidden)
  end

  it "refuses a scraper_editor, who can use the admin panel but not manage announcements" do
    sign_in_with_role(:scraper_editor)
    get admin_announcements_path
    expect(response).to have_http_status(:forbidden)
  end

  context "when signed in as an admin" do
    before { sign_in_with_role(:admin) }

    describe "the new announcement form" do
      before { travel_to(Time.utc(2026, 10, 15, 2, 30)) }

      it "starts the announcement now by default" do
        get new_admin_announcement_path
        expect(response.body).to include('value="2026-10-15T02:30:00"')
      end

      it "says the times are in UTC and how far Sydney is from it" do
        get new_admin_announcement_path
        expect(response.body).to include("Starts at (UTC)")
        expect(response.body).to include("Ends at (UTC)")
        expect(response.body).to include("Sydney is currently 11 hours ahead of UTC")
      end
    end

    it "labels the times as UTC when showing an announcement" do
      announcement = create(:announcement, starts_at: Time.utc(2026, 10, 15, 2, 30))
      get admin_announcement_path(announcement)
      expect(response.body).to include("15 October 2026, 2:30 am UTC")
    end

    it "lists announcements" do
      create(:announcement, body: "Listed notice")
      get admin_announcements_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Listed notice")
    end

    it "creates an announcement" do
      expect do
        post admin_announcements_path, params: { announcement: { body: "New notice", published: "1" } }
      end.to change(Announcement, :count).by(1)
      expect(Announcement.last).to have_attributes(body: "New notice", published: true)
    end

    it "updates an announcement" do
      announcement = create(:announcement, body: "Before")
      patch admin_announcement_path(announcement), params: { announcement: { body: "After" } }
      expect(announcement.reload.body).to eq "After"
    end

    it "deletes an announcement" do
      announcement = create(:announcement)
      expect { delete admin_announcement_path(announcement) }.to change(Announcement, :count).by(-1)
    end
  end
end
