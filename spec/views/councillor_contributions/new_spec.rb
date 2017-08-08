require 'spec_helper'

feature "Contributing new councillors for an authority" do
  let(:authority) { create(:authority, full_name: "Casey City Council") }

  context "when the feature flag is off" do
    it "isn't available" do
      visit new_authority_councillor_contribution_path(authority.short_name_encoded)

      expect(page.status_code).to eq 404
    end
  end

  context "when the feature flag is on" do
    around do |test|
      with_modified_env CONTRIBUTE_COUNCILLORS_ENABLED: "true" do
        test.run
      end
    end

    scenario "on the contribution page, display the name of the authority" do
      visit new_authority_councillor_contribution_path(authority.short_name_encoded)

      expect(page).to have_content("Casey City Council")
    end
  end
end
