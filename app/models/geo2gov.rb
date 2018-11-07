# frozen_string_literal: true

# Simple wrapper around http://geo2gov.com.au/ web service
class Geo2gov
  include HTTParty
  base_uri "geo2gov.com.au"

  def initialize(lat, lng)
    @lat = lat
    @lng = lng
    @response = self.class.get "http://geo2gov.com.au/json?location=#{lng}+#{lat}"
  end

  def lga_code
    census = @response["Census"]
    census.first["LGA"] if census
  end

  def jurisdictions
    response = @response["Response"]
    if response
      response.map { |r| r["Jurisdiction"] }.uniq
    else
      []
    end
  end

  # Return the local government jurisdiction.
  # Doing this by a process of elimination. Eliminate Federal and State, leaving Local.
  def lga_jurisdiction
    local = jurisdictions
    # NSW, QLD, VIC, SA, WA, Tasmania, NT, ACT
    %w[Federal ACT NSW QLD SA TAS VIC WA NT].each do |a|
      local.delete(a)
    end
    raise "Can't figure out the local government area for lat, lng: #{@lat}, #{@lng}" if local.count > 1
    local.first
  end

  def lga_name
    j = lga_jurisdiction
    j.split(":").last.tr("_", " ") + ", " + j.split(":").first if j
  end
end
