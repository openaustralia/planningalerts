# frozen_string_literal: true

class Alert < ApplicationRecord
  belongs_to :alert_subscriber, optional: true

  validates :radius_meters, numericality: { greater_than: 0, message: "isn't selected" }
  validate :validate_address

  before_validation :geocode_from_address, unless: :geocoded?
  include EmailConfirmable

  attr_writer :address_for_placeholder

  scope(:active, -> { where(confirmed: true, unsubscribed: false) })
  scope(:in_past_week, -> { where("created_at > ?", 7.days.ago) })

  before_create :attach_alert_subscriber

  def location=(loc)
    return unless loc

    self.lat = loc.lat
    self.lng = loc.lng
  end

  # TODO: This can probably be removed after being run on production
  #       because all future alerts will be created with an associated AlertSubscriber
  #       see spec/models/alert_spec.rb:11
  def self.create_alert_subscribers_for_existing_alerts
    Alert.find_in_batches do |batch|
      batch.each do |alert|
        alert.attach_alert_subscriber
        alert.save
      end
    end
  end

  def self.alerts_in_inactive_areas
    # find(:all).find_all{|a| a.in_inactive_area?}
    radius = 2
    c = Math.cos(radius / GeoKit::Mappable::EARTH_RADIUS_IN_KMS)
    s = Math.sin(radius / GeoKit::Mappable::EARTH_RADIUS_IN_KMS)
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

  def self.count_of_new_unique_email_created_on_date(date)
    alerts = where(confirmed: true).where("date(created_at) = ?", date).group(:email)

    alerts.reject do |alert|
      where(email: alert.email).where("created_at < ?", alert.created_at).any?
    end.count
  end

  def self.count_of_email_completely_unsubscribed_on_date(date)
    emails = where("date(unsubscribed_at) = ?", date).where(unsubscribed: true)
                                                     .distinct
                                                     .pluck(:email)

    emails.reject do |email|
      active.where(email: email).where("date(created_at) <= ?", date).any?
    end.count
  end

  def geocoded?
    location.present?
  end

  def unsubscribe!
    update!(unsubscribed: true, unsubscribed_at: Time.zone.now)
  end

  def subscription
    super
  end

  def address_for_placeholder
    @address_for_placeholder || "1 Sowerby St, Goulburn, NSW 2580"
  end

  # Name of the local government authority
  def lga_name
    # Cache value
    lga_name = self[:lga_name]
    unless lga_name
      lga_name = Geo2gov.new(lat, lng).lga_name
      self[:lga_name] = lga_name
      # TODO: Kind of wrong to do a save! here in what appears to the outside world like a simple accessor method
      save!
    end
    lga_name
  end

  # Given a list of alerts (with locations), find which LGAs (Local Government Authorities) they are in and
  # return the distribution (i.e. count) of authorities.
  def self.distribution_of_lgas(alerts)
    frequency_distribution(alerts.map(&:lga_name).compact)
  end

  # Pass an array of objects. Count the distribution of objects and return as a hash of object: :count
  def self.frequency_distribution(array)
    freq = {}
    array.each do |i|
      freq[i] = (freq[i] || 0) + 1
    end
    freq.to_a.sort { |i, j| -(i[1] <=> j[1]) }
  end

  def in_inactive_area?
    radius = 2

    c = Math.cos(radius / GeoKit::Mappable::EARTH_RADIUS_IN_KMS)
    s = Math.sin(radius / GeoKit::Mappable::EARTH_RADIUS_IN_KMS)
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
    Application.order("date_received DESC").near([location.lat, location.lng], radius_km, units: :km).where("date_scraped > ?", cutoff_time)
  end

  # Applications in the area of interest which have new comments made since we were last alerted
  def applications_with_new_comments
    Application.near([location.lat, location.lng], radius_km, units: :km)
               .joins(:comments)
               .where("comments.confirmed_at > ?", cutoff_time)
               .where("comments.confirmed" => true)
               .where("comments.hidden" => false).distinct
  end

  def applications_with_new_replies
    Application.near([location.lat, location.lng], radius_km, units: :km)
               .joins(:replies)
               .where("replies.received_at > ?", cutoff_time)
               .distinct
  end

  def new_comments
    comments = []
    # Doing this in this roundabout way because I'm not sure how to use "near" together with joins
    applications_with_new_comments.each do |application|
      comments += application.comments.visible.where("comments.confirmed_at > ?", cutoff_time)
    end
    comments
  end

  def new_replies
    replies = []
    # Doing this in this roundabout way because I'm not sure how to use "near" together with joins
    applications_with_new_replies.each do |application|
      replies += application.replies.where("replies.received_at > ?", cutoff_time)
    end
    replies
  end

  def cutoff_time
    last_sent || Date.yesterday
  end

  def radius_km
    radius_meters / 1000.0
  end

  def confirm!
    update!(confirmed: true)
  end

  # Process this email alert and send out an email if necessary. Returns number of applications and comments sent.
  def process!
    applications = recent_applications
    comments = new_comments
    replies = new_replies

    if !applications.empty? || !comments.empty? || !replies.empty?
      AlertNotifier.alert(self, applications, comments, replies).deliver_now
      self.last_sent = Time.zone.now
    end
    self.last_processed = Time.zone.now
    save!

    # Update the tallies on each application.
    applications.each do |application|
      application.increment(:no_alerted)
    end

    # Return number of applications, comments and replies sent
    [applications.size, comments.size, replies.size]
  end

  # This is a long-running method. Call with care
  # TODO: Untested method
  def self.process_all_active_alerts(info_logger = logger)
    batch_size = 100
    alerts = Alert.active.all
    no_batches = alerts.count / batch_size + 1
    time_between_batches = 24.hours / no_batches
    info_logger.info "Checking #{alerts.count} active alerts"
    info_logger.info "Splitting mailing for the next 24 hours into batches of size #{batch_size} roughly every #{time_between_batches / 60} minutes"

    time = Time.zone.now
    alerts.map(&:id).shuffle.each_slice(batch_size) do |alert_ids|
      Alert.delay(run_at: time).process_alerts(alert_ids)
      time += time_between_batches
    end
    info_logger.info "Mailing jobs for the next 24 hours queued"
  end

  # TODO: Untested method
  def self.process_alerts(alert_ids)
    # Only send alerts to confirmed users
    total_no_emails = 0
    total_no_applications = 0
    total_no_comments = 0
    Alert.find(alert_ids).each do |alert|
      no_applications, no_comments = alert.process!
      next if no_applications.zero? && no_comments.zero?

      total_no_applications += no_applications
      total_no_comments += no_comments
      total_no_emails += 1
    end

    # Update statistics. Updating the Stat at the end of each mail run has the advantage of not continiously invalidating
    # page caches during mail runs.
    Stat.emails_sent += total_no_emails
    Stat.applications_sent += total_no_applications
    EmailBatch.create!(no_emails: total_no_emails, no_applications: total_no_applications,
                       no_comments: total_no_comments)
    [total_no_emails, total_no_applications, total_no_comments]
  end

  def geocode_from_address
    @geocode_result = Location.geocode(address)

    return if @geocode_result.error || @geocode_result.all.many?

    self.location = @geocode_result
    self.address = @geocode_result.full_address
  end

  def attach_alert_subscriber
    self.alert_subscriber = AlertSubscriber.find_or_create_by(email: email)
  end

  private

  def validate_address
    # Only validate the street address if we used the geocoder
    return unless @geocode_result

    if @geocode_result.error
      errors.add(:address, @geocode_result.error)
    elsif @geocode_result.all.many?
      errors.add(:address, "isn't complete. Please enter a full street address, including suburb and state, e.g. #{@geocode_result.full_address}")
    end
  end
end
