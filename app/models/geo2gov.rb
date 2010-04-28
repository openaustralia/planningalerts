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
  
  def jurisdictions
    @response["Response"].map{|r| r["Jurisdiction"]}.uniq
  end
  
  # Return the local government jurisdiction.
  # Doing this by a process of elimination. Eliminate Federal and State, leaving Local.
  def lga_jurisdiction
    local = jurisdictions
    # NSW, QLD, VIC, SA, WA, Tasmania, NT, ACT
    %w(Federal ACT NSW QLD SA TAS VIC WA).each do |a|
      local.delete(a)
    end
    raise "Can't figure out the local government area" unless local.count == 1
    local.first
  end
end