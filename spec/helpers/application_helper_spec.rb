require 'spec_helper'

describe ApplicationHelper do

  it "should convert a distance in metres to simple concise text" do
    helper.meters_in_words(2000).should == "2 km"
    helper.meters_in_words(500).should == "500 m"
  end

end
