# Represents a square area on the ground
class Area
  attr_reader :centre, :lower_left, :upper_right

  def initialize(centre, size_in_metres)
    lower_centre = centre.endpoint(180, size_in_metres / 2)
    upper_centre = centre.endpoint(0, size_in_metres / 2)
    centre_left = centre.endpoint(270, size_in_metres / 2)
    centre_right = centre.endpoint(90, size_in_metres / 2)
    @centre = centre
    @lower_left = Location.new(lower_centre.lat, centre_left.lng)
    @upper_right = Location.new(upper_centre.lat, centre_right.lng)
  end
end

