class Alert < ActiveRecord::Base
  validates_numericality_of :radius_meters, :greater_than => 0, :message => "isn't selected"
  validate :validate_email, :validate_address
  
  before_validation :geocode
  before_create :set_confirm_info
  before_create :remove_other_alerts_for_this_address
  
  named_scope :confirmed, :conditions => {:confirmed => true}

  def location=(l)
    if l
      self.lat = l.lat
      self.lng = l.lng
    end
  end
  
  def self.alerts_in_inactive_areas
    find(:all).find_all{|a| !a.in_active_area?}
  end
  
  # Pass an array of objects. Count the distribution of objects and return as a hash of :object => :count
  def self.frequency_distribution(a)
    freq = {}
    a.each do |a|
      freq[a] = (freq[a] || 0) + 1
    end
    freq.to_a.sort {|a, b| -(a[1] <=> b[1])}
  end
  
  def in_active_area?
    Application.find(:first, :origin => [location.lat, location.lng], :within => 2) != nil
  end
  
  def location
    Location.new(lat, lng) if lat && lng
  end
  
  # Applications that have been scraped since the last time the user was sent an alert
  def recent_applications
    Application.find(:all, :origin => [location.lat, location.lng], :within => radius_km, :conditions => ['date_scraped > ?', last_sent || Date.yesterday])
  end
  
  def radius_km
    radius_meters / 1000.0
  end
  
  # This is a long-running method. Call with care
  # TODO: Untested method
  def self.send_alerts(info_logger = logger)
    # Only send alerts to confirmed users
    no_emails = 0
    no_applications = 0
    alerts = Alert.find_all_by_confirmed(true)
    info_logger.info "Checking #{alerts.count} confirmed users"
    alerts.each do |alert|
      applications = alert.recent_applications
      no_applications += applications.size
      unless applications.empty?
        AlertNotifier.deliver_alert(alert, applications)
        no_emails += 1
      end
    end
    info_logger.info "Sent #{no_applications} applications to #{no_emails} people!"
  end
  
  private
  
  def remove_other_alerts_for_this_address
    Alert.delete_all(:email => email, :address => address)
  end
  
  def set_confirm_info
    # TODO: Should check that this is unique across all alerts and if not try again
    self.confirm_id = Digest::MD5.hexdigest(rand.to_s + Time.now.to_s)[0...20]
  end

  def geocode
    # Only geocode if location hasn't been set
    if self.lat.nil? && self.lng.nil?
      @geocode_result = Location.geocode(address)
      self.location = @geocode_result
      self.address = @geocode_result.full_address
    end
  end
  
  def validate_address
    # Only validate the street address if we used the geocoder
    if @geocode_result
      if address == ""
        errors.add(:address, "can't be empty")
      elsif location.nil?
        errors.add(:address, "isn't valid")
      elsif @geocode_result.country_code != "AU"
        errors.add(:address, "isn't in Australia")
      elsif @geocode_result.all.size > 1
        errors.add(:address, "isn't complete. Please enter a full street address, including suburb and state, e.g. #{@geocode_result.full_address}")
      elsif @geocode_result.accuracy < 6
        errors.add(:address, "isn't complete. We saw that address as \"#{@geocode_result.full_address}\" which we don't recognise as a full street address. Check your spelling and make sure to include suburb and state")
      end
    end
  end
  
  def validate_email
    if email == ""
      errors.add(:email, "can't be empty")
    elsif !email.include?('@')
      errors.add(:email, "isn't valid")      
    else
      begin
        TMail::Address.parse(email)
      rescue
        errors.add(:email, "isn't valid")
      end
    end
  end
end
