# frozen_string_literal: true

require "spec_helper"

describe "councillor_contributions/new" do
  it "displays the full name of the assigned authority" do
    assign(:authority, create(:authority, full_name: "Casey City Council"))
    assign(:councillor_contribution, CouncillorContribution.new)

    render

    expect(rendered).to have_content("Casey City Council")
  end

  context "with an invalid councillor" do
    before do
      invalid_councillor = build(
        :suggested_councillor,
        name: nil,
        email: nil
      )
      invalid_councillor.validate

      assign(:authority, create(:authority))
      assign(
        :councillor_contribution,
        build(:councillor_contribution, suggested_councillors: [invalid_councillor], authority: @authority)
      )
    end

    it "shows error messages" do
      render

      expect(rendered).to have_content("Email can't be blank")
      expect(rendered).to have_content("Name can't be blank")
    end
  end
end
