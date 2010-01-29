class Location
  attr_reader :lat, :lng

  def initialize(lat, lng)
    @lat, @lng = lat, lng
  end

  # Super-thin veneer over Geokit geocoder
  def self.geocode(address)
    l = Geokit::Geocoders::GoogleGeocoder.geocode(address)
    Location.new(l.lat, l.lng)
  end
  
  # Coordinates of bottom-left and top-right corners of a box centred on the current location
  # with a given size in metres
  def box_with_size_in_metres(size_in_metres)
    [Location.new(-33.773508234721, 150.62309060152), Location.new(-33.771709765279, 150.62543539848)]
  end
  
  def ==(a)
    a.lat == lat && a.lng == lng
  end
end