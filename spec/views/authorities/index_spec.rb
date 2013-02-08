require 'spec_helper'

describe "authorities/index.haml" do
  it "should show a list of the authorities" do
    a1 = mock_model(Authority, :full_name => "Wombat District Council", :short_name_encoded => "wombat", :broken? => false)
    a2 = mock_model(Authority, :full_name => "Kangaroo City Council", :short_name_encoded => "kangaroo", :broken? => false)
    assign(:authorities, [["NSW", [a1, a2]]]) 
    render
    rendered.should have_content(a1.full_name)
    rendered.should have_content(a2.full_name)
  end
end