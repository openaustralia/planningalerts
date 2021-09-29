# frozen_string_literal: true

module SessionHelpers
  def sign_in_as_admin
    admin = create(:admin)

    visit nimda_root_path

    within("#new_user") do
      fill_in "Email", with: admin.email
      fill_in "Password", with: admin.password
    end
    click_button "Sign in"

    expect(page).to have_content "Signed in successfully"
  end
end
