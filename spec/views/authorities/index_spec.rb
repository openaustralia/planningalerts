# frozen_string_literal: true

require "spec_helper"

describe "authorities/index.haml" do
  it "shows a list of the authorities" do
    a1 = mock_model(Authority, id: 1, full_name: "Wombat District Council", short_name_encoded: "wombat", covered?: false)
    a2 = mock_model(Authority, id: 2, full_name: "Kangaroo City Council", short_name_encoded: "kangaroo", covered?: false)
    assign(:authorities, [a1, a2])
    assign(:working_authority_ids, [1, 2])
    render
    expect(rendered).to have_content(a1.full_name)
    expect(rendered).to have_content(a2.full_name)
  end
end
