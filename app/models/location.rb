# Super thin veneer over Geokit geocoder and the results of the geocoding. The other main difference with
# geokit vanilla is that the distances are all in meters and the geocoding is biased towards Australian addresses

class Location < SimpleDelegator
  attr_accessor :original_address

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
    r = Geokit::Geocoders::GoogleGeocoder3.geocode(address, bias: "au")
    r = r.all.find{|l| Location.new(l).in_correct_country?} || r
    l = Location.new(r)
    l.original_address = address
    l
  end

  def in_correct_country?
    country_code == "AU"
  end

  def suburb
    city
  end

  def postcode
    zip
  end

  def error
    # Only checking for errors on geocoding
    if original_address
      if original_address == ""
        "Please enter a street address"
      elsif lat.nil? || lng.nil?
        "Sorry we don’t understand that address. Try one like ‘1 Sowerby St, Goulburn, NSW’"
      elsif !in_correct_country?
        "Unfortunately we only cover Australia. It looks like that address is in another country."
      elsif accuracy < 5
        "Please enter a full street address like ‘36 Sowerby St, Goulburn, NSW’"
      end
    end
  end

  # Distance given is in metres
  def endpoint(bearing, distance)
    Location.new(__getobj__.endpoint(bearing, distance / 1000.0, units: :kms))
  end

  # Distance (in metres) to other point
  def distance_to(l)
    __getobj__.distance_to(l.__getobj__, units: :kms) * 1000.0
  end

  def full_address
    __getobj__.full_address.sub(", Australia", "")
  end

  def all
    __getobj__.all.find_all{|l| Location.new(l).in_correct_country?}.map{|l| Location.new(l)}
  end

  def ==(a)
    lat == a.lat && lng == a.lng
  end
end
