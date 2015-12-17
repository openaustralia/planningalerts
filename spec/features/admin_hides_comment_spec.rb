require 'spec_helper'

feature "Admin hides comment" do
  background do
    VCR.use_cassette('planningalerts') do
      create(:confirmed_comment, id: 1)
    end

    admin = create(:admin)

    visit new_user_session_path
    within("#new_user") do
      fill_in "Email", with: admin.email
      fill_in "Password", with: admin.password
    end
    click_button "Sign in"
    expect(page).to have_content "Signed in successfully"
  end

  scenario "successfully" do
    visit admin_root_path
    click_link "Comments"

    within("#comment_1") do
      click_link "Edit"
    end

    check "Hidden"
    click_button "Update Comment"

    expect(page).to have_content("Comment was successfully updated")
    expect(page).to have_content("Hidden true")
  end

  scenario "successfully when writing to councillor feature is enabled" do
    with_modified_env COUNCILLORS_ENABLED: 'true' do
      visit admin_root_path
      click_link "Comments"

      within("#comment_1") do
        click_link "Edit"
      end

      check "Hidden"
      click_button "Update Comment"

      expect(page).to have_content("Comment was successfully updated")
      expect(page).to have_content("Hidden true")
    end
  end

  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end
end
