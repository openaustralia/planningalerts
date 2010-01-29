class Location
  attr_reader :lat, :lng

  def initialize(lat, lng)
    @lat, @lng = lat, lng
  end

  def self.geokit(g)
    Location.new(g.lat, g.lng)
  end

  # Super-thin veneer over Geokit geocoder
  def self.geocode(address)
    geokit(Geokit::Geocoders::GoogleGeocoder.geocode(address))
  end
  
  def to_s
    to_geokit.to_s
  end
  
  # Coordinates of bottom-left and top-right corners of a box centred on the current location
  # with a given size in metres
  def box_with_size_in_metres(size_in_metres)
    lower_center = endpoint(180, size_in_metres / 2)
    upper_center = endpoint(0, size_in_metres / 2)
    center_left = endpoint(270, size_in_metres / 2)
    center_right = endpoint(90, size_in_metres / 2)
    lower_left = Location.new(lower_center.lat, center_left.lng)
    upper_right = Location.new(upper_center.lat, center_right.lng)
    [lower_left, upper_right]
  end
  
  def ==(a)
    a.lat == lat && a.lng == lng
  end
  
  def to_geokit
    Geokit::LatLng.new(lat, lng)
  end
  
  # Distance given is in metres
  def endpoint(bearing, distance)
    Location.geokit(to_geokit.endpoint(bearing, distance / 1000.0, :units => :kms))
  end
  
  # Distance (in metres) to other point
  def distance_to(l)
    to_geokit.distance_to(l.to_geokit, :units => :kms) * 1000.0
  end
end