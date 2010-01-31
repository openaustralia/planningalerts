class User < ActiveRecord::Base
  set_table_name :user

  validate :validate_email, :validate_address
  before_validation :geocode
  
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
    @geocode_result = Location.geocode(address)
    self.location = @geocode_result
  end
  
  def validate_address
    if location.nil?
      errors.add(:address, "Please enter a valid street address")
    elsif @geocode_result.country_code != "AU"
      errors.add(:address, "Please enter a valid street address in Australia")
    elsif @geocode_result.all.size > 1
      errors.add(:address, "Oops! That's not quite enough information. Please enter a full street address, including suburb and state, e.g. #{@geocode_result.full_address}")
    elsif @geocode_result.accuracy < 6
      errors.add(:address, "Oops! We saw that address as \"#{@geocode_result.full_address}\" which we don't recognise as a full street address. Check your spelling and make sure to include suburb and state")
    end
  end
  
  def validate_email
    TMail::Address.parse(email)
  rescue
    errors.add(:email, "Please enter a valid email address")
  end
end
