require "spec_helper"

feature "User signs up to donate monthly" do
  it "successfully" do
    visit new_backer_path

    click_button "Donate $3.50 each month"

    expect(page).to have_content "Thank you for backing PlanningAlerts"
  end
end
