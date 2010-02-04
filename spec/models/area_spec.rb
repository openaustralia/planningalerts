require File.dirname(__FILE__) + '/../spec_helper'

describe Area do
  it "should calculate the coordinates of a square box on the surface of the earth centred on the first point" do
    centre = Location.new(-33.772609, 150.624263)
    result = Area.new(centre, 200)
    expected_lower_left = Location.new(-33.773508234721, 150.62309060152)
    expected_upper_right = Location.new(-33.771709765279, 150.62543539848)
    
    # Result should be accurate to within ten metres
    result.lower_left.distance_to(expected_lower_left).should < 10
    result.upper_right.distance_to(expected_upper_right).should < 10
  end
end