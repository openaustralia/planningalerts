# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"

describe Feed do
  describe "#valid?" do
    it "lodgement_date_start" do
      feed = described_class.new(base_url: "http://foo.com", lodgement_date_start: "2012")
      expect(feed).not_to be_valid
      expect(feed.errors.messages).to eq(lodgement_date_start: ["is not a correctly formatted date"])
    end
  end

  describe ".create_from_url" do
    it "parses out parameters from a full url" do
      f = described_class.create_from_url("http://localhost:3000/atdis/feed/1/atdis/1.0/applications.json?lodgement_date_end=2019-01-01&lodgement_date_start=2018-12-01&street=Foo")
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
    it "is false if all filters are nil" do
      f = described_class.new(base_url: "http://foo.com")
      expect(f).not_to be_filters_set
    end

    it "is true if any filter is set" do
      f = described_class.new(base_url: "http://foo.com", lodgement_date_start: "2012")
      expect(f).to be_filters_set
    end
  end

  describe "#applications" do
    it "justs delegate to the ATDIS gem" do
      f = described_class.new(base_url: "http://foo.com", lodgement_date_start: "2012")
      atdis = double
      applications = double
      allow(ATDIS::Feed).to receive(:new).with("http://foo.com", "Sydney").and_return(atdis)
      allow(atdis).to receive(:applications).with(lodgement_date_start: "2012").and_return(applications)
      expect(f.applications).to eq applications
    end
  end

  describe "#persisted?" do
    it "alwayses be false" do
      f = described_class.new(base_url: "http://foo.com")
      expect(f.persisted?).to be false
    end
  end

  describe ".example_path" do
    it "returns the file path to where the examples are stored" do
      expect(described_class.example_path(6, 1)).to eq "app/views/atdis/examples/example6_page1.json"
    end

    it "returns a path to an existing file" do
      expect(File.exist?(described_class.example_path(1, 1))).to be true
    end
  end
end
