class User < ActiveRecord::Base
  set_table_name :user
  
  validate :validate_email

  before_create :geocode
  
  def location=(l)
    if l
      self.lat = l.lat
      self.lng = l.lng
    end
  end
  
  def location
    Location.new(lat, lng) if lat && lng
  end
  
  private
  
  def geocode
    # For the time being just set latitude/longitude to zero so that we can save this record
    self.location = Location.geocode(address)
  end
  
  def validate_email
    TMail::Address.parse(email)
  rescue
    errors.add(:email, "Please enter a valid email address")
  end
end
