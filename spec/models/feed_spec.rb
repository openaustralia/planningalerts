require File.dirname(__FILE__) + '/../spec_helper'

describe Feed do
  let(:feed) { Feed.new }

  describe "#lodgement_date_start" do
    it "date assignment" do
      feed.lodgement_date_start = Date.new(2012,2,1)
      feed.lodgement_date_start.should == Date.new(2012,2,1)
    end

    it "string assignment" do
      feed.lodgement_date_start = "2012-02-01"
      feed.lodgement_date_start.should == "2012-02-01"
    end

    it "string assignment invalid date" do
      feed.lodgement_date_start = "2012"
      feed.lodgement_date_start.should == "2012"
    end
  end

  describe "#valid?" do
    it "lodgement_date_start" do
      feed.lodgement_date_start = "2012"
      feed.should_not be_valid
      feed.errors.messages.should == {:lodgement_date_start => ["is not a correctly formatted date"]}
    end
  end

  describe ".create_from_url" do
    it do
      f = double
      Feed.should_receive(:new).with(:base_url => "http://localhost:3000/atdis/feed/1/atdis/1.0/applications.json").and_return(f)
      Feed.create_from_url("http://localhost:3000/atdis/feed/1/atdis/1.0/applications.json").should == f
    end
  end

  describe ".new" do
    it { Feed.new(:base_url => "http://foo.com").base_url.should == "http://foo.com"}
  end
end