require 'spec_helper'

describe StaticController, "about" do
  it "should show a list of the authorities" do
    a1 = mock_model(Authority, :full_name => "Wombat District Council", :short_name_encoded => "wombat")
    a2 = mock_model(Authority, :full_name => "Kangaroo City Council", :short_name_encoded => "kangaroo")
    assigns[:authorities] = [a1, a2]
    render "static/about"
    response.should include_text(a1.full_name)
    response.should include_text(a2.full_name)
  end
end