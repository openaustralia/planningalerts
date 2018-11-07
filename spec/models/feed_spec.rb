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
end
