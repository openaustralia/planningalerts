# frozen_string_literal: true

module SessionHelpers
  def sign_in_as_admin
    admin = create(:admin)

    visit admin_root_path

    fill_in "Your email", with: admin.email
    fill_in "Password", with: admin.password
    click_button "Sign in"

    expect(page).to have_content "Signed in successfully"
  end
end
