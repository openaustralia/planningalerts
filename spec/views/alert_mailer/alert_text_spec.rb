# frozen_string_literal: true

require "spec_helper"

# Text only email
describe "alert_mailer/alert.text.erb" do
  let(:application) do
    create(:geocoded_application,
           description: "Alterations & additions",
           address: "24 Bruce Road Glenbrook")
  end

  before do
    assign(:applications, [application])
    assign(:comments, [])
    assign(:host, "foo.com")
  end

  context "when there is a comment to an authority" do
    before do
      comment = create(:comment,
                       name: "Matthew Landauer",
                       application:)

      assign(:comments, [comment])
      assign(:alert, create(:alert))

      render
    end

    it { expect(rendered).to have_content("Matthew Landauer commented") }
    it { expect(rendered).to have_content("on “Alterations & additions” at 24 Bruce Road Glenbrook") }
  end
end
