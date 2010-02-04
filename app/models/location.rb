# Super thin veneer over Geokit geocoder and the results of the geocoding. The other main difference with
# geokit vanilla is that the distances are all in meters and the geocoding is biased towards Australian addresses

class Location < SimpleDelegator
  def initialize(*params)
    if params.count == 2
      super(Geokit::LatLng.new(*params))
    elsif params.count == 1
      super(params.first)
    else
      raise "Unexpected number of parameters"
    end
  end

  def self.geocode(address)
    Location.new(Geokit::Geocoders::GoogleGeocoder.geocode(address, :bias => "au"))
  end
  
  # Distance given is in metres
  def endpoint(bearing, distance)
    Location.new(__getobj__.endpoint(bearing, distance / 1000.0, :units => :kms))
  end
  
  # Distance (in metres) to other point
  def distance_to(l)
    __getobj__.distance_to(l.__getobj__, :units => :kms) * 1000.0
  end
  
  def full_address
    __getobj__.full_address.sub(", Australia", "")
  end
  
  def ==(a)
    lat == a.lat && lng == a.lng
  end
end