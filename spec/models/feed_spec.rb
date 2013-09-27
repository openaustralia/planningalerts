require File.dirname(__FILE__) + '/../spec_helper'

describe Feed do
  describe "#valid?" do
    it "lodgement_date_start" do
      feed = Feed.new(:lodgement_date_start => "2012")
      feed.should_not be_valid
      feed.errors.messages.should == {:lodgement_date_start => ["is not a correctly formatted date"]}
    end
  end
end