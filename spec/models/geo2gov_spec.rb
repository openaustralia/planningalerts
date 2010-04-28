require 'spec_helper'

describe Geo2gov do
  describe "Blue Mountains" do
    before :each do
      Geo2gov.should_receive(:get).with("http://geo2gov.com.au/json?location=150.624263+-33.772609").and_return(
        "Census" => [{"MSR" => "11", "LGA" => "LGA10900"}],
        "Response" => [
          {"Jurisdiction" => "Federal"},
          {"Jurisdiction" => "Federal"},
          {"Jurisdiction" => "NSW:Blue_Mountains"},
          {"Jurisdiction" => "NSW"},
          {"Jurisdiction" => "NSW"}
        ]
      )
      @g = Geo2gov.new(-33.772609, 150.624263)
    end
  
    it "should return the LGA code for the BLue Mountains for a point in the Blue Mountains" do
      @g.lga_code.should == "LGA10900"
    end
  
    it "should return a list of jurisdictions that this point is in" do
      @g.jurisdictions.should == ["Federal", "NSW:Blue_Mountains", "NSW"]
    end
  
    it "should return the LGA jurisdiction" do
      @g.lga_jurisdiction.should == "NSW:Blue_Mountains"
    end
    
    it "should return the name of the LGA (with the state) in a human readable form" do
      @g.lga_name.should == "Blue Mountains, NSW"
    end
  end

  describe "Invalid point" do
    before :each do
      Geo2gov.should_receive(:get).with("http://geo2gov.com.au/json?location=0+0").and_return("Error" => "Failed to find any divisions")
      @g = Geo2gov.new(0, 0)
    end

    it "should return sensible nil values" do
      @g.lga_code.should be_nil
      @g.jurisdictions.should == []
      @g.lga_jurisdiction.should be_nil
      @g.lga_name.should be_nil
    end
  end
end
