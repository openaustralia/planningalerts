require 'spec_helper'

describe "councillor_contributions/new" do
  it "displays the full name of the assigned authority" do
    assign(:authority, create(:authority, full_name: "Casey City Council"))
    assign(:councillor_contribution, CouncillorContribution.new)

    render

    expect(rendered).to have_content("Casey City Council")
  end
end
