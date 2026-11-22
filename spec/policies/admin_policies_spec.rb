# frozen_string_literal: true

require "spec_helper"

# Who can do what in the admin interface. Each row lists the roles allowed;
# everyone else, including people with no role, must be refused.
describe Admin do
  all_roles = [:admin, :api_editor, :scraper_editor, nil]

  # policy => { action => roles allowed }
  allowed = {
    Admin::AlertPolicy => {
      index?: %i[admin], show?: %i[admin], update?: %i[admin], destroy?: %i[admin], create?: []
    },
    Admin::AnnouncementPolicy => {
      index?: %i[admin], show?: %i[admin], create?: %i[admin], update?: %i[admin], destroy?: %i[admin]
    },
    Admin::ApiKeyPolicy => {
      index?: %i[admin api_editor], show?: %i[admin api_editor], create?: %i[admin api_editor],
      update?: %i[admin api_editor], destroy?: []
    },
    Admin::ApiUsagesPolicy => { index?: %i[admin api_editor] },
    Admin::ApplicationsPolicy => {
      index?: %i[admin scraper_editor], show?: %i[admin scraper_editor],
      edit?: %i[admin], update?: %i[admin], destroy?: %i[admin]
    },
    Admin::AuthorityPolicy => {
      index?: %i[admin scraper_editor], show?: %i[admin scraper_editor], create?: %i[admin scraper_editor],
      update?: %i[admin scraper_editor], import?: %i[admin scraper_editor], destroy?: []
    },
    Admin::BackgroundJobsPolicy => { index?: %i[admin] },
    Admin::CommentPolicy => {
      index?: %i[admin], show?: %i[admin], update?: %i[admin], resend?: %i[admin], destroy?: []
    },
    Admin::ReportPolicy => { index?: %i[admin], show?: %i[admin], destroy?: %i[admin] },
    Admin::RolePolicy => { index?: %i[admin], show?: %i[admin], update?: [] },
    Admin::TestEmailsPolicy => { index?: %i[admin], create?: %i[admin] },
    Admin::UserPolicy => {
      index?: %i[admin api_editor], show?: %i[admin api_editor], update?: %i[admin], destroy?: %i[admin]
    }
  }

  def user_with(role)
    create(:confirmed_user).tap { |user| user.add_role(role) if role }
  end

  allowed.each do |policy, actions|
    describe policy do
      actions.each do |action, roles|
        all_roles.each do |role|
          permitted = roles.include?(role)
          it "#{permitted ? 'lets' : "doesn't let"} #{role || 'someone with no role'} #{action.to_s.delete_suffix('?')}" do
            expect(policy.new(user_with(role), nil).public_send(action)).to be permitted
          end
        end
      end
    end
  end

  # Scopes decide which records the index lists
  {
    Admin::AlertPolicy => [Alert, %i[admin]],
    Admin::AnnouncementPolicy => [Announcement, %i[admin]],
    Admin::ApiKeyPolicy => [ApiKey, %i[admin api_editor]],
    Admin::ApplicationsPolicy => [Application, %i[admin scraper_editor]],
    Admin::AuthorityPolicy => [Authority, %i[admin scraper_editor]],
    Admin::CommentPolicy => [Comment, %i[admin]],
    Admin::ReportPolicy => [Report, %i[admin]],
    Admin::RolePolicy => [Role, %i[admin]],
    Admin::UserPolicy => [User, %i[admin api_editor]]
  }.each do |policy, (model, roles)|
    describe "#{policy}::Scope" do
      all_roles.each do |role|
        permitted = roles.include?(role)
        it "#{permitted ? 'shows' : 'hides'} every #{model.name.underscore.humanize(capitalize: false)} " \
           "#{permitted ? 'to' : 'from'} #{role || 'someone with no role'}" do
          relation = policy::Scope.new(user_with(role), model).resolve

          expect(relation.to_sql).to eq(permitted ? model.all.to_sql : model.none.to_sql)
        end
      end
    end
  end

  it "lets anyone who can sign in to admin see the admin home page" do
    expect(Admin::HomesPolicy.new(user_with(:scraper_editor), nil).index?).to be true
  end
end
