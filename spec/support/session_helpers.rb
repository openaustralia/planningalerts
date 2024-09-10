# frozen_string_literal: true

module SessionHelpers
  def sign_in_as_admin
    admin = create(:confirmed_user)
    admin.add_role(:admin)

    visit admin_root_path

    fill_in "Your email", with: admin.email
    fill_in "Password", with: admin.password
    click_on "Sign in"

    expect(page).to have_content "Signed in successfully"
  end
end
