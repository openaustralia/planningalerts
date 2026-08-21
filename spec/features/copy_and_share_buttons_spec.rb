# frozen_string_literal: true

require "spec_helper"

describe "Copy and share buttons" do
  # Note that headless Firefox (the javascript driver) has no Web Share API,
  # so the share button specs exercise the clipboard fallback branch, which is
  # the same branch people hit in the wild when navigator.share is unavailable.
  let(:application) { create(:geocoded_application, council_reference: "005") }

  describe "copy button on the external link page" do
    before do
      visit external_application_path(application)
    end

    it "copies the reference and confirms it", :js do
      click_on "Copy"

      expect(page).to have_content("Copied")
    end

    it "tells the person when copying fails", :js do
      page.execute_script(<<~JS)
        Object.defineProperty(navigator, "clipboard", {
          value: { writeText: () => Promise.reject(new Error("denied")) }
        });
      JS
      click_on "Copy"

      expect(page).to have_content("Failed")
    end

    it "tells the person rather than throwing when the clipboard API is unavailable", :js do
      page.execute_script('Object.defineProperty(navigator, "clipboard", { value: undefined });')
      click_on "Copy"

      expect(page).to have_content("Failed")
    end
  end

  describe "share button on the application page" do
    before do
      visit application_path(application)
    end

    it "copies the link and confirms it", :js do
      click_on "Share this application"

      expect(page).to have_content("Link copied")
    end

    it "tells the person when copying the link fails", :js do
      page.execute_script(<<~JS)
        Object.defineProperty(navigator, "clipboard", {
          value: { writeText: () => Promise.reject(new Error("denied")) }
        });
      JS
      click_on "Share this application"

      expect(page).to have_content("Couldn't copy link")
    end

    it "tells the person rather than throwing when the clipboard API is unavailable", :js do
      page.execute_script('Object.defineProperty(navigator, "clipboard", { value: undefined });')
      click_on "Share this application"

      expect(page).to have_content("Couldn't copy link")
    end
  end
end
