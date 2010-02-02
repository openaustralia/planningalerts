class User < ActiveRecord::Base
  set_table_name :user

  validates_numericality_of :area_size_meters, :greater_than => 0, :message => "isn't selected"
  validate :validate_email, :validate_address
  
  before_validation :geocode
  before_create :set_confirm_info
  
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
  
  def set_confirm_info
    # TODO: Should check that this is unique across all alerts and if not try again
    self.confirm_id = Digest::MD5.hexdigest(rand.to_s + Time.now.to_s)[0...20]
  end

  def geocode
    @geocode_result = Location.geocode(address)
    self.location = @geocode_result
    self.address = @geocode_result.full_address
  end
  
  def validate_address
    if address == ""
      errors.add(:street_address, "can't be empty")
    elsif location.nil?
      errors.add(:street_address, "isn't valid")
    elsif @geocode_result.country_code != "AU"
      errors.add(:street_address, "isn't in Australia")
    elsif @geocode_result.all.size > 1
      errors.add(:street_address, "isn't complete. Please enter a full street address, including suburb and state, e.g. #{@geocode_result.full_address}")
    elsif @geocode_result.accuracy < 6
      errors.add(:street_address, "isn't complete. We saw that address as \"#{@geocode_result.full_address}\" which we don't recognise as a full street address. Check your spelling and make sure to include suburb and state")
    end
  end
  
  def validate_email
    if email == ""
      errors.add(:email_address, "can't be empty")
    else
      begin
        TMail::Address.parse(email)
      rescue
        errors.add(:email_address, "isn't valid")
      end
    end
  end
end
