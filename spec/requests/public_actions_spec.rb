# frozen_string_literal: true

require "spec_helper"

# Happy paths for public actions that no other spec requests
describe "Public actions" do
  # TODO: #2166 Include this in spec/spec_helper.rb instead
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:confirmed_user, name: "Alex Example", email: "alex@example.com", password: "old-password") }

  it "gives an authority's boundary as GeoJSON for the map" do
    square = "MULTIPOLYGON(((151.0 -33.0, 151.1 -33.0, 151.1 -33.1, 151.0 -33.1, 151.0 -33.0)))"
    authority = create(:authority, boundary: RGeo::Geographic.spherical_factory(srid: 4326).parse_wkt(square))

    get boundary_authority_path(authority.short_name_encoded, format: :json)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include("type" => "Feature")
    expect(response.parsed_body["geometry"]).to include("type" => "MultiPolygon")
  end

  describe "when signed in" do
    before { sign_in user }

    it "stops an alert" do
      alert = create(:alert, user:, address: "12 Example Street, Exampleton NSW 2000")

      delete alert_path(alert)

      expect(alert.reload.unsubscribed).to be true
      expect(response).to redirect_to(alerts_path)
      expect(flash[:notice]).to include("12 Example Street, Exampleton NSW 2000")
    end

    it "creates a trial API key" do
      post api_keys_path

      expect(user.api_keys.count).to eq 1
      expect(response).to redirect_to(api_keys_url)
    end

    it "updates the account" do
      patch user_registration_path, params: { user: { name: "Alex New-Name", current_password: "old-password" } }

      expect(user.reload.name).to eq "Alex New-Name"
      expect(response).to have_http_status(:redirect)
    end

    it "closes the account" do
      delete user_registration_path

      expect(User.exists?(user.id)).to be false
      expect(response).to have_http_status(:redirect)
    end

    it "signs out" do
      delete destroy_user_session_path

      expect(response).to have_http_status(:redirect)
      expect(controller.current_user).to be_nil
    end
  end

  it "sets a new password from the reset email" do
    token = user.send_reset_password_instructions

    put user_password_path, params: {
      user: { reset_password_token: token, password: "new-password", password_confirmation: "new-password" }
    }

    expect(user.reload.valid_password?("new-password")).to be true
    expect(response).to have_http_status(:redirect)
  end

  describe "a locked account" do
    before { user.lock_access!(send_instructions: false) }

    it "can ask for the unlock email again" do
      # On Rails 7.1 request specs put deliver_later on the test queue (see #2313)
      expect { post user_unlock_path, params: { user: { email: "alex@example.com" } } }
        .to have_enqueued_mail(DeviseMailer, :unlock_instructions)
      expect(response).to have_http_status(:redirect)
    end

    it "unlocks from the link in that email" do
      token = user.send_unlock_instructions

      get user_unlock_path(unlock_token: token)

      expect(user.reload.access_locked?).to be false
      expect(response).to have_http_status(:redirect)
    end
  end
end
