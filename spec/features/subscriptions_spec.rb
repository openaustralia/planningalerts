require "spec_helper"

feature "Subscriptions" do
  context "visit page" do
    scenario "without campaign tracking" do
      visit new_subscription_path
      expect(page).to have_content "$99"
    end

    scenario "test_2_cohort_3 campaign" do
      visit new_subscription_path(utm_campaign: "test_2_cohort_3")
      expect(page).to have_content "$49"
    end
  end
end
