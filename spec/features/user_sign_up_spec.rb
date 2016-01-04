require "spec_helper"

feature "Signing up for an API account" do
  scenario "Successfully signing up" do
    visit "/api/howto"
    click_link "Register for an account"

    fill_in "Email", with: "henare@oaf.org.au"
    fill_in "Your name", with: "Henare Degan"
    fill_in "Organisation name", with: "OpenAustralia Foundation"
    fill_in "Password", with: "password"
    click_button "Register"

    expect(page).to have_content "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
    expect(User.find_by(email: "henare@oaf.org.au").name).to eq "Henare Degan"
    expect(User.find_by(email: "henare@oaf.org.au").organisation).to eq "OpenAustralia Foundation"
  end
end
