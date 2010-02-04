# Represents a square area on the ground
class Area
  attr_reader :lower_left, :upper_right

  def initialize(centre, size_in_metres)
    lower_center = centre.endpoint(180, size_in_metres / 2)
    upper_center = centre.endpoint(0, size_in_metres / 2)
    center_left = centre.endpoint(270, size_in_metres / 2)
    center_right = centre.endpoint(90, size_in_metres / 2)
    @lower_left = Location.new(lower_center.lat, center_left.lng)
    @upper_right = Location.new(upper_center.lat, center_right.lng)
  end
end

