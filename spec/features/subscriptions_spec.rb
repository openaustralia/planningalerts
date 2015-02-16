require "spec_helper"

feature "Subscriptions" do
  context "visit page" do
    scenario "without campaign tracking" do
      visit new_subscription_path
      expect(page).to have_content "$99"
    end
  end
end
