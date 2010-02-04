# Represents a square area on the ground
class Area
  attr_accessor :lower_left, :upper_right

  def self.lower_left_and_upper_right(lower_left, upper_right)
    area = Area.new
    area.lower_left, area.upper_right = lower_left, upper_right
    area
  end
  
  def self.centre_and_size(centre, size_in_metres)
    lower_centre = centre.endpoint(180, size_in_metres / 2)
    upper_centre = centre.endpoint(0, size_in_metres / 2)
    centre_left = centre.endpoint(270, size_in_metres / 2)
    centre_right = centre.endpoint(90, size_in_metres / 2)
    area = Area.new
    area.lower_left = Location.new(lower_centre.lat, centre_left.lng)
    area.upper_right = Location.new(upper_centre.lat, centre_right.lng)
    area
  end
  
  def centre
    Location.new((lower_left.lat + upper_right.lat) / 2, (lower_left.lng + upper_right.lng) / 2)
  end
end

