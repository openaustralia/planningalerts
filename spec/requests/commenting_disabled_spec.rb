# frozen_string_literal: true

require "spec_helper"

describe "Commenting disabled for a person" do
  include Devise::Test::IntegrationHelpers

  let(:application) { create(:geocoded_application, authority: create(:authority, email: "planning@example.gov.au")) }
  let(:user) { create(:confirmed_user, comments_disabled: true) }
  let(:draft) { create(:comment, user:, application:, text: "My draft") }

  before { sign_in(user) }

  it "refuses to create a comment" do
    expect do
      post application_comments_path(application), params: { comment: { name: "Jo Citizen", text: "Hello", address: "1 Example St" } }
    end.not_to change(Comment, :count)

    expect(response).to have_http_status(:forbidden)
    expect(response.body).to include("Commenting is turned off for your account")
  end

  it "refuses to update a draft made before the flag was set" do
    patch application_comment_path(application, draft), params: { comment: { text: "Changed" } }

    expect(response).to have_http_status(:forbidden)
    expect(draft.reload.text).to eq "My draft"
  end

  it "refuses to publish a draft made before the flag was set" do
    post publish_application_comment_path(application, draft)

    expect(response).to have_http_status(:forbidden)
    expect(draft.reload).not_to be_published
  end

  it "gives the usual refusal when the reason is something else" do
    someone_elses = create(:comment, application:)

    get preview_comment_path(someone_elses)

    expect(response).to have_http_status(:redirect)
  end

  it "still lets them delete a draft" do
    patch application_comment_path(application, draft, clear: 1)

    expect(Comment.exists?(draft.id)).to be false
  end
end
