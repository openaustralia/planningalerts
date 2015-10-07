require 'spec_helper'

feature "View comments on an application" do
  scenario "seeing the latest comment first" do
    VCR.use_cassette('planningalerts') do
      application = create(:application)
      create(:confirmed_comment, text: "newest", updated_at: Date.today, application: application)
      create(:confirmed_comment, text: "middle", updated_at: Date.yesterday, application: application)
      create(:confirmed_comment, text: "oldest", updated_at: 3.days.ago, application: application)

      visit(application_path(application))
    end

    expect(page.all('.comment-item').map {|c| c.find('.comment-text').text})
      .to eq ["newest", "middle", "oldest"]
  end
end
