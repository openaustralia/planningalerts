# frozen_string_literal: true

require File.dirname(__FILE__) + "/../spec_helper"

describe Feed do
  describe "#valid?" do
    it "lodgement_date_start" do
      feed = Feed.new(base_url: "http://foo.com", lodgement_date_start: "2012")
      expect(feed).not_to be_valid
      expect(feed.errors.messages).to eq(lodgement_date_start: ["is not a correctly formatted date"])
    end
  end

  describe ".create_from_url" do
    it "should parse out parameters from a full url" do
      f = Feed.create_from_url("http://localhost:3000/atdis/feed/1/atdis/1.0/applications.json?lodgement_date_end=2019-01-01&lodgement_date_start=2018-12-01&street=Foo")
      expect(f.base_url).to eq "http://localhost:3000/atdis/feed/1/atdis/1.0"
      expect(f.page).to eq 1
      expect(f.street).to eq "Foo"
      expect(f.lodgement_date_start).to eq Date.new(2018, 12, 1)
      expect(f.lodgement_date_end).to eq Date.new(2019, 1, 1)
      expect(f.last_modified_date_start).to be_nil
      expect(f.last_modified_date_end).to be_nil
    end
  end

  describe "#filters_set?" do
    it "should be false if all filters are nil" do
      f = Feed.new(base_url: "http://foo.com")
      expect(f.filters_set?).to be_falsey
    end

    it "should be true if any filter is set" do
      f = Feed.new(base_url: "http://foo.com", lodgement_date_start: "2012")
      expect(f.filters_set?).to be_truthy
    end
  end

  describe "#applications" do
    it "should just delegate to the ATDIS gem" do
      f = Feed.new(base_url: "http://foo.com", lodgement_date_start: "2012")
      atdis = double
      applications = double
      expect(ATDIS::Feed).to receive(:new).with("http://foo.com").and_return(atdis)
      expect(atdis).to receive(:applications).with(lodgement_date_start: "2012").and_return(applications)
      expect(f.applications).to eq applications
    end
  end
end
