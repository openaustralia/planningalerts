class Alert < ActiveRecord::Base
  validates_numericality_of :radius_meters, :greater_than => 0, :message => "isn't selected"
  validate :validate_address
  
  before_validation :geocode
  before_create :remove_other_alerts_for_this_address
  acts_as_email_confirmable
  after_create :send_confirmation_email
  
  def send_confirmation_email
    AlertNotifier.deliver_confirm(self)
  end
  
  def location=(l)
    if l
      self.lat = l.lat
      self.lng = l.lng
    end
  end
  
  def self.alerts_in_inactive_areas
    #find(:all).find_all{|a| a.in_inactive_area?}
    radius = 2    
    c = Math.cos(radius/GeoKit::Mappable::EARTH_RADIUS_IN_KMS)
    s = Math.sin(radius/GeoKit::Mappable::EARTH_RADIUS_IN_KMS)
    multiplier = GeoKit::Mappable::EARTH_RADIUS_IN_KMS
    command = 
      %|
        SELECT * FROM `alerts` WHERE NOT EXISTS (
          SELECT * FROM `applications` WHERE (
            lat > DEGREES(ASIN(SIN(RADIANS(alerts.lat))*#{c} - COS(RADIANS(alerts.lat))*#{s}))
            AND lat < DEGREES(ASIN(SIN(RADIANS(alerts.lat))*#{c} + COS(RADIANS(alerts.lat))*#{s}))
            AND lng > alerts.lng - DEGREES(ATAN2(#{s}, #{c} * COS(RADIANS(alerts.lat))))
            AND lng < alerts.lng + DEGREES(ATAN2(#{s}, #{c} * COS(RADIANS(alerts.lat))))
            AND (ACOS(least(1,COS(RADIANS(alerts.lat))*COS(RADIANS(alerts.lng))*COS(RADIANS(lat))*COS(RADIANS(lng))+
              COS(RADIANS(alerts.lat))*SIN(RADIANS(alerts.lng))*COS(RADIANS(lat))*SIN(RADIANS(lng))+
              SIN(RADIANS(alerts.lat))*SIN(RADIANS(lat))))*#{multiplier})
              <= #{radius}
          ) LIMIT 1
        )
      |
    Alert.find_by_sql(command)
  end
  
  # Name of the local government authority
  def lga_name
    # Cache value
    lga_name = read_attribute(:lga_name)
    unless lga_name
      lga_name = Geo2gov.new(lat, lng).lga_name
      write_attribute(:lga_name, lga_name)
      # TODO: Kind of wrong to do a save! here in what appears to the outside world like a simple accessor method
      save!
    end
    lga_name
  end
  
  # Given a list of alerts (with locations), find which LGAs (Local Government Authorities) they are in and
  # return the distribution (i.e. count) of authorities.
  def self.distribution_of_lgas(alerts)
    frequency_distribution(alerts.map {|alert| alert.lga_name}.compact)
  end
  
  # Pass an array of objects. Count the distribution of objects and return as a hash of :object => :count
  def self.frequency_distribution(a)
    freq = {}
    a.each do |a|
      freq[a] = (freq[a] || 0) + 1
    end
    freq.to_a.sort {|a, b| -(a[1] <=> b[1])}
  end
  
  def in_inactive_area?
    radius = 2
    point = GeoKit::LatLng.new(lat, lng)
    
    c = Math.cos(radius/GeoKit::Mappable::EARTH_RADIUS_IN_KMS)
    s = Math.sin(radius/GeoKit::Mappable::EARTH_RADIUS_IN_KMS)
    multiplier = GeoKit::Mappable::EARTH_RADIUS_IN_KMS
    Application.find_by_sql(
      %|
        SELECT * FROM `applications` WHERE (
          lat IS NOT NULL AND lng IS NOT NULL
          AND lat > DEGREES(ASIN(SIN(RADIANS(#{lat}))*#{c} - COS(RADIANS(#{lat}))*#{s}))
          AND lat < DEGREES(ASIN(SIN(RADIANS(#{lat}))*#{c} + COS(RADIANS(#{lat}))*#{s}))
          AND lng > #{lng} - DEGREES(ATAN2(#{s}, #{c} * COS(RADIANS(#{lat}))))
          AND lng < #{lng} + DEGREES(ATAN2(#{s}, #{c} * COS(RADIANS(#{lat}))))
          AND (ACOS(least(1,COS(RADIANS(#{lat}))*COS(RADIANS(#{lng}))*COS(RADIANS(lat))*COS(RADIANS(lng))+
            COS(RADIANS(#{lat}))*SIN(RADIANS(#{lng}))*COS(RADIANS(lat))*SIN(RADIANS(lng))+
            SIN(RADIANS(#{lat}))*SIN(RADIANS(lat))))*#{multiplier})
            <= #{radius}
        ) LIMIT 1
      |
      ).empty?
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
      if @geocode_result.error
        errors.add(:address, @geocode_result.error)
      elsif @geocode_result.all.size > 1
        errors.add(:address, "isn't complete. Please enter a full street address, including suburb and state, e.g. #{@geocode_result.full_address}")
      end
    end
  end
end
