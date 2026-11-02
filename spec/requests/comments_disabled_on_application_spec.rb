# frozen_string_literal: true

require "spec_helper"

describe "Comments disabled on an application" do
  include Devise::Test::IntegrationHelpers

  let(:application) { create(:geocoded_application, :comments_disabled, authority: create(:authority, email: "planning@example.gov.au")) }
  let(:user) { create(:confirmed_user) }
  let(:draft) { create(:comment, user:, application:, text: "My draft") }

  before { sign_in(user) }

  it "refuses to create a comment" do
    expect do
      post application_comments_path(application), params: { comment: { name: "Jo Citizen", text: "Hello", address: "1 Example St" } }
    end.not_to change(Comment, :count)

    expect(response).to have_http_status(:forbidden)
    expect(response.body).to include("Commenting is turned off for this application")
  end

  it "refuses to update a draft made before comments were disabled" do
    patch application_comment_path(application, draft), params: { comment: { text: "Changed" } }

    expect(response).to have_http_status(:forbidden)
    expect(draft.reload.text).to eq "My draft"
  end

  it "refuses to publish a draft made before comments were disabled, so it is never sent" do
    post publish_application_comment_path(application, draft)

    expect(response).to have_http_status(:forbidden)
    expect(draft.reload).not_to be_published
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  it "explains the refusal even when the URL names a different application" do
    post publish_application_comment_path(create(:geocoded_application, council_reference: "OPEN/1"), draft)

    expect(response).to have_http_status(:forbidden)
    expect(response.body).to include("Commenting is turned off for this application")
  end

  it "gives the usual refusal for someone else's draft, so it doesn't reveal which application the draft is on" do
    someone_elses = create(:comment, application:)

    post publish_application_comment_path(application, someone_elses)

    expect(response).to have_http_status(:redirect)
    expect(someone_elses.reload).not_to be_published
  end

  it "explains commenting is turned off for the application, rather than the person's own restriction, when both apply" do
    user.update!(comments_disabled: true)

    post application_comments_path(application), params: { comment: { name: "Jo Citizen", text: "Hello", address: "1 Example St" } }

    expect(response.body).to include("Commenting is turned off for this application")
    expect(response.body).not_to include("Commenting is turned off for your account")
  end

  it "shows a draft's preview without the edit and publish buttons" do
    get preview_comment_path(draft)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Commenting is turned off for this application")
    expect(response.body).not_to include("Edit comment")
    expect(response.body).not_to include(publish_application_comment_path(draft))
  end

  it "never shows the staff reason" do
    get application_path(application)

    expect(response.body).not_to include(application.comments_disabled_reason)
  end
end
