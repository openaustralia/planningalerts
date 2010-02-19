require 'spec_helper'

describe ApiController do
  describe "call=authority" do
    it "should find recent 100 applications for an authority with the most recently scraped first" do
      authority, result = mock, mock

      Authority.should_receive(:find_by_short_name).with("Blue Mountains").and_return(authority)
      authority.should_receive(:applications).with(:limit=>100, :order=>"date_scraped DESC").and_return(result)

      get :index, :call => "authority", :authority => "Blue Mountains"
      assigns[:applications].should == result
    end
  end
end
