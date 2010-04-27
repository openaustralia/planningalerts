# Simple wrapper around http://geo2gov.com.au/ web service
class Geo2gov
  include HTTParty
  base_uri 'geo2gov.com.au'
  
  def initialize(lat, lng)
    @response = self.class.get "http://geo2gov.com.au/json?location=#{lng}+#{lat}"
  end
  
  def lga_code
    @response["Census"].first["LGA"]
  end
end