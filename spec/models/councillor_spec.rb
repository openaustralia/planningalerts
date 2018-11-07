# frozen_string_literal: true

require "spec_helper"

describe Councillor do
  describe "#prefixed_name" do
    it { expect(create(:councillor, name: "Steve").prefixed_name).to eq "local councillor Steve" }
  end

  describe "#initials" do
    it { expect(create(:councillor, name: "Vandarna").initials).to eq "V" }
    it { expect(create(:councillor, name: "Vandarna Adams").initials).to eq "V A" }
    it { expect(create(:councillor, name: "vandarna adams").initials).to eq "V A" }
    it { expect(create(:councillor, name: "Kate O'Neil").initials).to eq "K O" }
    it { expect(create(:councillor, name: "Kate \"Smithy\" Smiles").initials).to eq "K S" }
  end

  describe "validations" do
    it { expect(Councillor.new).to_not be_valid }
    it { expect(Councillor.new(authority: create(:authority))).to_not be_valid }
    it { expect(Councillor.new(authority: create(:authority), image_url: "http://foobar.com")).to_not be_valid }

    it { expect(Councillor.new(authority: create(:authority), email: "foo@bar.com")).to be_valid }
    it { expect(Councillor.new(authority: create(:authority), email: "foo@bar.com", image_url: "https://foobar.com")).to be_valid }
  end

  describe "#writeit_id" do
    it "combines the popolo_id with the authority popolo_url" do
      expect(create(:councillor, popolo_id: "authority/foo_bar").writeit_id)
        .to eql "https://raw.githubusercontent.com/openaustralia/australian_local_councillors_popolo/master/data/NSW/local_councillor_popolo.json/person/authority/foo_bar"
    end
  end

  describe "#cached_image_url" do
    it "adds the popolo_id to the cache storage url" do
      expect(create(:councillor, popolo_id: "authority/foo_bar").cached_image_url)
        .to eql "https://australian-local-councillors-images.s3.amazonaws.com/authority/foo_bar-80x88.jpg"
    end
  end

  describe "#cached_image_available?" do
    around do |example|
      VCR.use_cassette("planningalerts") do
        example.run
      end
    end

    it "is true if the image can be found" do
      councillor = build(:councillor, popolo_id: "albury_city_council/kevin_mack")

      expect(councillor.cached_image_available?).to be true
    end

    it "is false if the image can't be found" do
      councillor = build(:councillor, popolo_id: "authority/foo_bar")

      expect(councillor.cached_image_available?).to be false
    end
  end
end
