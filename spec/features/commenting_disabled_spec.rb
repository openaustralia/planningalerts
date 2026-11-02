# frozen_string_literal: true

require "spec_helper"

describe "Commenting disabled for a person" do
  include Devise::Test::IntegrationHelpers

  let(:application) { create(:geocoded_application, authority: create(:authority, email: "planning@example.gov.au")) }
  let(:user) { create(:confirmed_user, name: "Jane Ng", comments_disabled: true, comments_disabled_reason: "Impersonating another person") }

  before do
    sign_in(user)
  end

  it "replaces the comment form with an explanation" do
    visit application_path(application)

    expect(page).to have_content("Commenting is turned off for your account")
    expect(page).to have_link("please contact us", href: documentation_contact_path)
    expect(page).to have_no_content("Add your own comment")
    expect(page).to have_no_field("Your comment")
  end

  it "doesn't invite them to comment when there are no comments" do
    visit application_path(application)

    expect(page).to have_no_link("Make a comment now")
    expect(page).to have_no_link("Be the first to comment")
  end

  it "doesn't invite them to comment when there are comments" do
    create(:published_comment, application:)

    visit application_path(application)

    expect(page).to have_no_link("Make a comment now")
    expect(page).to have_no_link("Add your own comment")
  end

  it "never shows the staff reason" do
    visit application_path(application)

    expect(page).to have_no_content("Impersonating another person")
  end

  it "leaves existing comments alone" do
    comment = create(:published_comment, user:, application:)

    visit application_path(application)

    expect(page).to have_content(comment.text)
  end

  it "lets the person comment again once cleared" do
    user.update!(comments_disabled: false)

    visit application_path(application)

    expect(page).to have_link("Make a comment now")
    expect(page).to have_field("Your comment")
  end
end
