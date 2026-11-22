# frozen_string_literal: true

require "spec_helper"

# During maintenance the site runs on a read-only database user, so any write
# fails with a Postgres permissions error
describe "Maintenance mode" do
  # TODO: #2166 Include this in spec/spec_helper.rb instead
  include Devise::Test::IntegrationHelpers

  before { Flipper.enable(:maintenance_mode) }

  it "tells people the site is read-only" do
    get about_path

    expect(response.body).to include("We're doing some maintenance on Planning Alerts")
  end

  it "explains why a change didn't save, rather than showing an error page" do
    user = create(:confirmed_user)
    alert = create(:alert, user:)
    sign_in user
    allow(Alert).to receive(:find).and_return(alert)
    allow(alert).to receive(:unsubscribe!)
      .and_raise(ActiveRecord::StatementInvalid, "PG::InsufficientPrivilege: ERROR:  permission denied for table alerts")

    delete alert_path(alert), headers: { "HTTP_REFERER" => alerts_url }

    expect(response).to redirect_to(alerts_url)
    expect(flash[:alert]).to eq "PlanningAlerts is currently in read-only maintenance mode. Please try again later."
  end
end
