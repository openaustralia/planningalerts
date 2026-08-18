# frozen_string_literal: true

require "spec_helper"

describe "Hiding an application" do
  let(:hidden_reason) { "Contains personal information" }

  describe "admin hides an application" do
    before do
      create(:geocoded_application, id: 1, council_reference: "DA/2026/1")
    end

    it "successfully" do
      sign_in_as_admin

      click_on "Applications"

      click_on "Edit"

      check "Hidden"
      fill_in "Hidden reason", with: hidden_reason
      click_on "Update Application"

      expect(page).to have_content("Application was successfully updated")
      expect(page).to have_content("Hidden\nyes")
      expect(page).to have_content(hidden_reason)
    end
  end

  describe "viewing a hidden application" do
    context "when a reason was given" do
      before do
        create(:geocoded_application, :hidden, id: 1, hidden_reason:)
      end

      it "shows an explanation page with the reason" do
        visit application_path(id: 1)

        expect(page.status_code).to eq 403
        expect(page).to have_content("This application has been hidden")
        expect(page).to have_content(hidden_reason)
        expect(page).to have_content("The application record has not been deleted")
      end
    end

    context "when no reason was given" do
      before do
        create(:geocoded_application, :hidden, id: 1, hidden_reason: nil)
      end

      it "shows an explanation page with the default reason" do
        visit application_path(id: 1)

        expect(page.status_code).to eq 403
        expect(page).to have_content("This application has been hidden")
        expect(page).to have_content("It has been removed from public view.")
      end
    end
  end
end
