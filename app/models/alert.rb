# frozen_string_literal: true

class Alert < ApplicationRecord
  validates :radius_meters, numericality: { greater_than: 0, message: "isn't selected" }
  validate :validate_address

  before_validation :geocode_from_address, unless: :geocoded?
  include EmailConfirmable

  scope(:active, -> { where(confirmed: true, unsubscribed: false) })
  scope(:in_past_week, -> { where("created_at > ?", 7.days.ago) })

  def location=(loc)
    return unless loc

    self.lat = loc.lat
    self.lng = loc.lng
  end

  def geocoded?
    location.present?
  end

  def unsubscribe!
    update!(unsubscribed: true, unsubscribed_at: Time.zone.now)
  end

  def location
    Location.new(lat: lat, lng: lng) if lat && lng
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

  def geocode_from_address
    @geocode_result = GoogleGeocodeService.call(address)

    return if @geocode_result.error || @geocode_result.all.many?

    self.location = @geocode_result.top
    self.address = @geocode_result.top.full_address
  end

  private

  def validate_address
    # Only validate the street address if we used the geocoder
    return unless @geocode_result

    if @geocode_result.error
      errors.add(:address, @geocode_result.error)
    elsif @geocode_result.all.many?
      errors.add(:address, "isn't complete. Please enter a full street address, including suburb and state, e.g. #{@geocode_result.top.full_address}")
    end
  end
end
