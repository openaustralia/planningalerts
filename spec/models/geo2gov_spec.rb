require 'spec_helper'

describe Geo2gov do
  it "should return the LGA code for the BLue Mountains for a point in the Blue Mountains" do
    g = Geo2gov.new(-33.772609, 150.624263)
    g.lga_code.should == "LGA10900"
  end
end
