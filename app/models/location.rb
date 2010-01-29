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
  
  def ==(a)
    a.lat == lat && a.lng == lng
  end
end