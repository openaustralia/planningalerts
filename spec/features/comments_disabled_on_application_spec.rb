# frozen_string_literal: true

require "spec_helper"

describe "Comments disabled on an application" do
  include Devise::Test::IntegrationHelpers

  let(:application) { create(:geocoded_application, :comments_disabled, authority: create(:authority, email: "planning@example.gov.au")) }

  it "tells people who aren't signed in that commenting is turned off, instead of inviting them to sign in" do
    visit application_path(application)

    expect(page).to have_content("Commenting is turned off for this application")
    expect(page).to have_no_link("Sign in", href: new_user_session_path, exact: true)
    expect(page).to have_no_link("Make a comment now")
    expect(page).to have_no_link("Be the first to comment")
  end

  it "replaces the comment form for a signed in person" do
    sign_in(create(:confirmed_user))

    visit application_path(application)

    expect(page).to have_content("Commenting is turned off for this application")
    expect(page).to have_content("Existing comments have not been changed")
    expect(page).to have_link("please contact us", href: documentation_contact_path)
    expect(page).to have_no_content("Add your own comment")
    expect(page).to have_no_field("Your comment")
  end

  it "shows the application's message, not the person's own restriction, when both apply" do
    sign_in(create(:confirmed_user, comments_disabled: true))

    visit application_path(application)

    expect(page).to have_content("Commenting is turned off for this application")
    expect(page).to have_no_content("Commenting is turned off for your account")
  end

  it "keeps existing comments visible" do
    comment = create(:published_comment, application:, text: "An earlier comment")

    visit application_path(application)

    expect(page).to have_content(comment.text)
  end

  it "restores the form once comments are turned back on" do
    application.update!(comments_disabled: false)
    sign_in(create(:confirmed_user))

    visit application_path(application)

    expect(page).to have_field("Your comment")
  end
end
