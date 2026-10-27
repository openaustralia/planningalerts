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

    expect(page).to have_content("Commenting has been turned off for your account")
    expect(page).to have_link("please contact us", href: documentation_contact_path)
    expect(page).to have_no_field("Your comment")
  end

  it "never shows the staff reason" do
    visit application_path(application)

    expect(page).to have_no_content("Impersonating another person")
  end

  it "refuses to create a comment" do
    expect do
      page.driver.post application_comments_path(application), comment: { name: "Jane Ng", text: "Hello", address: "1 Foo St" }
    end.not_to change(Comment, :count)

    expect(page.driver.status_code).to eq 403
  end

  it "refuses to publish a draft made before the flag was set" do
    draft = create(:comment, user:, application:)

    page.driver.post publish_application_comment_path(application, draft)

    expect(page.driver.status_code).to eq 403
    expect(draft.reload).not_to be_published
  end

  it "leaves existing comments alone" do
    comment = create(:published_comment, user:, application:)

    visit application_path(application)

    expect(page).to have_content(comment.text)
  end

  it "lets the person comment again once cleared" do
    user.update!(comments_disabled: false)

    visit application_path(application)

    expect(page).to have_field("Your comment")
  end
end
