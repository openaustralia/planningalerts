class User < ActiveRecord::Base
  set_table_name :user
  
  before_create :geocode
  
  def location=(l)
    self.lat = l.lat
    self.lng = l.lng
  end
  
  def location
    Location.new(self.lat, self.lng)
  end
  
  private
  
  def geocode
    # For the time being just set latitude/longitude to zero so that we can save this record
    self.location = Location.geocode(self.address)
  end
end
