# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"

describe "Location" do
  describe "#distance_to" do
    it "returns results consistent with endpoint method" do
      loc1 = Location.new(lat: -33.772609, lng: 150.624263)
      # 500 metres NE
      loc2 = loc1.endpoint(45.0, 500.0)
      expect(loc1.distance_to(loc2)).to be_within(0.1).of(500)
    end

    it "returns a known distance" do
      loc1 = Location.new(lat: -33.772609, lng: 150.624263)
      loc2 = Location.new(lat: -33.772, lng: 150.624)
      expect(loc1.distance_to(loc2)).to be_within(0.1).of(72)
    end
  end

  describe "#heading_to" do
    it "returns results consistent with endpoint method" do
      loc1 = Location.new(lat: -33.772609, lng: 150.624263)
      # 500 metres NE
      loc2 = loc1.endpoint(45.0, 500.0)
      expect(loc1.heading_to(loc2)).to be_within(0.1).of(45)
    end
  end
end
