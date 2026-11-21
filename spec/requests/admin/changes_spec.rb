# frozen_string_literal: true

require "spec_helper"

# Happy paths for admin changes that no other spec makes
describe "Admin changes" do
  # TODO: #2166 Include this in spec/spec_helper.rb instead
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:confirmed_user).tap { |user| user.add_role(:admin) } }

  before { sign_in admin }

  it "updates an API key's daily limit" do
    api_key = create(:api_key)

    patch admin_api_key_path(api_key), params: { api_key: { daily_limit: 5000 } }

    expect(api_key.reload.daily_limit).to eq 5000
    expect(response).to redirect_to(admin_api_key_path(api_key))
  end

  it "deletes an application" do
    application = create(:geocoded_application)

    delete admin_application_path(application)

    expect(Application.exists?(application.id)).to be false
    expect(response).to redirect_to(admin_applications_path)
  end

  it "adds an authority" do
    # The form's checkbox always sends disabled, which the column needs
    post admin_authorities_path, params: {
      authority: { full_name: "Exampleton City Council", short_name: "Exampleton", state: "NSW", disabled: "0" }
    }

    authority = Authority.find_by!(full_name: "Exampleton City Council")
    expect(response).to redirect_to(admin_authority_path(authority))
  end

  it "updates an authority" do
    authority = create(:authority)

    patch admin_authority_path(authority), params: { authority: { full_name: "Exampleton City Council" } }

    expect(authority.reload.full_name).to eq "Exampleton City Council"
    expect(response).to redirect_to(admin_authority_path(authority))
  end

  it "resends a comment to the council" do
    application = create(:geocoded_application, authority: create(:contactable_authority))
    comment = create(:published_comment, application:)

    # On Rails 7.1 request specs put deliver_later on the test queue (see #2313)
    expect { post resend_admin_comment_path(comment) }
      .to have_enqueued_mail(CommentMailer, :notify_authority).with(comment)
    expect(response).to redirect_to(admin_comment_path(comment))
  end

  it "deletes a report" do
    report = create(:report)

    delete admin_report_path(report)

    expect(Report.exists?(report.id)).to be false
    expect(response).to redirect_to(admin_reports_path)
  end

  it "deletes a user" do
    user = create(:confirmed_user)

    delete admin_user_path(user)

    expect(User.exists?(user.id)).to be false
    expect(response).to redirect_to(admin_users_path)
  end
end
