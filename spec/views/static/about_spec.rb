require 'spec_helper'

describe "static/about.haml" do
  it "should show a list of the authorities" do
    a1 = mock_model(Authority, :full_name => "Wombat District Council", :short_name_encoded => "wombat")
    a2 = mock_model(Authority, :full_name => "Kangaroo City Council", :short_name_encoded => "kangaroo")
    assign(:authorities, [["NSW", [a1, a2]]]) 
    render
    rendered.should contain(a1.full_name)
    rendered.should contain(a2.full_name)
  end
end