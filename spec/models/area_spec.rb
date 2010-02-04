require File.dirname(__FILE__) + '/../spec_helper'

describe Area do
  it "should calculate the coordinates of a square box on the surface of the earth centred on the first point" do
    centre = Location.new(-33.772609, 150.624263)
    result = Area.centre_and_size(centre, 200)
    expected_lower_left = Location.new(-33.773508234721, 150.62309060152)
    expected_upper_right = Location.new(-33.771709765279, 150.62543539848)
    
    # Result should be accurate to within ten metres
    result.lower_left.distance_to(expected_lower_left).should < 10
    result.upper_right.distance_to(expected_upper_right).should < 10
  end
  
  it "should construct an area using two coordinates for the lower left and upper right corner" do
    p1 = Location.new(1.0, 2.0)
    p2 = Location.new(3.0, 4.0)
    area = Area.lower_left_and_upper_right(p1, p2)
    area.lower_left.should == p1
    area.upper_right.should == p2
  end
end