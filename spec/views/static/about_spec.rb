require 'spec_helper'

describe StaticController, "about" do
  it "should show a list of the authorities" do
    a1 = mock_model(Authority, :full_name_and_state => "Wombat District Council, NSW", :short_name_encoded => "wombat")
    a2 = mock_model(Authority, :full_name_and_state => "Kangaroo City Council, NSW", :short_name_encoded => "kangaroo")
    assigns[:authorities] = [a1, a2]
    render "static/about"
    response.should include_text(a1.full_name_and_state)
    response.should include_text(a2.full_name_and_state)
  end
end