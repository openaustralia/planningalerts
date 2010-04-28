require 'spec_helper'

describe Geo2gov do
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
  end
  
  it "should return the LGA code for the BLue Mountains for a point in the Blue Mountains" do
    g = Geo2gov.new(-33.772609, 150.624263)
    g.lga_code.should == "LGA10900"
  end
  
  it "should return a list of jurisdictions that this point is in" do
    g = Geo2gov.new(-33.772609, 150.624263)
    g.jurisdictions.should == ["Federal", "NSW:Blue_Mountains", "NSW"]
  end
  
  it "should return the LGA jurisdiction" do
    g = Geo2gov.new(-33.772609, 150.624263)
    g.lga_jurisdiction.should == "NSW:Blue_Mountains"
  end
end
