# frozen_string_literal: true

require "spec_helper"

# The admin controllers check for an admin role before any policy runs, and
# turn a policy's refusal into a "Not authorised" page. The policies
# themselves are in spec/policies/admin_policies_spec.rb.
describe "Admin access" do
  # TODO: #2166 Include this in spec/spec_helper.rb instead
  include Devise::Test::IntegrationHelpers

  def sign_in_with(role)
    sign_in(create(:confirmed_user).tap { |user| user.add_role(role) })
  end

  it "refuses people with no admin role" do
    sign_in create(:confirmed_user)

    get admin_root_path

    expect(response).to have_http_status(:forbidden)
    expect(response.body).to eq "Not authorised"
  end

  it "lets an API editor manage API keys but not comments" do
    sign_in_with(:api_editor)

    get admin_api_keys_path
    expect(response).to have_http_status(:ok)

    get admin_comments_path
    expect(response).to have_http_status(:forbidden)
  end

  it "lets a scraper editor manage authorities but not users" do
    sign_in_with(:scraper_editor)

    get admin_authorities_path
    expect(response).to have_http_status(:ok)

    get admin_users_path
    expect(response).to have_http_status(:forbidden)
  end

  # Their routes only match for admins, so anyone else gets a 404
  %w[/admin/jobs /admin/flipper /admin/split].each do |path|
    it "keeps #{path} to admins" do
      sign_in_with(:scraper_editor)

      get path

      expect(response).to have_http_status(:not_found)
    end
  end
end
