require "spec_helper"

describe Geo2gov do
  describe "Blue Mountains" do
    before :each do
      expect(Geo2gov).to receive(:get).with("http://geo2gov.com.au/json?location=150.624263+-33.772609").and_return(
        "Census" => [{ "MSR" => "11", "LGA" => "LGA10900" }],
        "Response" => [
          { "Jurisdiction" => "Federal" },
          { "Jurisdiction" => "Federal" },
          { "Jurisdiction" => "NSW:Blue_Mountains" },
          { "Jurisdiction" => "NSW" },
          { "Jurisdiction" => "NSW" }
        ]
      )
      @g = Geo2gov.new(-33.772609, 150.624263)
    end

    it "should return the LGA code for the BLue Mountains for a point in the Blue Mountains" do
      expect(@g.lga_code).to eq("LGA10900")
    end

    it "should return a list of jurisdictions that this point is in" do
      expect(@g.jurisdictions).to eq(["Federal", "NSW:Blue_Mountains", "NSW"])
    end

    it "should return the LGA jurisdiction" do
      expect(@g.lga_jurisdiction).to eq("NSW:Blue_Mountains")
    end

    it "should return the name of the LGA (with the state) in a human readable form" do
      expect(@g.lga_name).to eq("Blue Mountains, NSW")
    end
  end

  describe "Invalid point" do
    before :each do
      expect(Geo2gov).to receive(:get).with("http://geo2gov.com.au/json?location=0+0").and_return("Error" => "Failed to find any divisions")
      @g = Geo2gov.new(0, 0)
    end

    it "should return sensible nil values" do
      expect(@g.lga_code).to be_nil
      expect(@g.jurisdictions).to eq([])
      expect(@g.lga_jurisdiction).to be_nil
      expect(@g.lga_name).to be_nil
    end
  end
end
