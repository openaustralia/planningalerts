# typed: strict
# frozen_string_literal: true

class Alert < ApplicationRecord
  extend T::Sig

  belongs_to :user
  # TODO: Remove accepts_nested_attributes_for after users purely sign up for alerts by being logged in
  accepts_nested_attributes_for :user

  VALID_RADIUS_METERS_VALUES = T.let([
    Rails.configuration.planningalerts_small_zone_size,
    Rails.configuration.planningalerts_medium_zone_size,
    Rails.configuration.planningalerts_large_zone_size
  ].freeze, T::Array[Integer])

  validates :radius_meters, numericality: { greater_than: 0 }
  validates :radius_meters, inclusion: { in: VALID_RADIUS_METERS_VALUES }
  validate :validate_address
  # We want to make sure that a certain user can't have multiple alerts for the same address even if some of
  # them haven't been confirmed yet. We also need to allow there to be multiple unsubscribed alerts with the
  # same address to allow people to do multiple rounds of subscribing and unsubscribing.
  validates :address, uniqueness: { scope: %i[user_id unsubscribed] }, unless: :unsubscribed?
  validates :address, presence: true

  before_validation :geocode_from_address, unless: :geocoded?
  before_create :set_confirm_info

  scope(:confirmed, -> { where(confirmed: true) })
  scope(:active, -> { where(confirmed: true, unsubscribed: false) })
  scope(:in_past_week, -> { where("created_at > ?", 7.days.ago) })

  delegate :email, to: :user

  # lat and lng are only populated on save (where they are stored as not null).
  # so they start off being nil. We're just overriding the type signature here.
  # TODO: Move geocoding to a service so that these never have to be nil
  sig { returns(T.nilable(Float)) }
  def lat
    self[:lat]
  end

  sig { returns(T.nilable(Float)) }
  def lng
    self [:lng]
  end

  sig { params(loc: T.nilable(Location)).void }
  def location=(loc)
    return unless loc

    self.lat = loc.lat
    self.lng = loc.lng
  end

  sig { returns(T::Boolean) }
  def geocoded?
    location.present?
  end

  sig { void }
  def unsubscribe!
    unsubscribe_with_reason!(nil)
  end

  sig { void }
  def unsubscribe_by_bounce!
    unsubscribe_with_reason!("bounce")
  end

  sig { params(reason: T.nilable(String)).void }
  def unsubscribe_with_reason!(reason)
    update!(unsubscribed: true, unsubscribed_at: Time.zone.now, unsubscribed_by: reason)
  end

  sig { returns(T.nilable(Location)) }
  def location
    Location.build(lat:, lng:)
  end

  # Applications that have been initially scraped since the last time the user was sent an alert
  # If the application is updated (with a more recent date_scraped) it will not
  # be included with the results.
  sig { returns(T.untyped) }
  def recent_new_applications
    Application.with_current_version
               .order("first_date_scraped DESC")
               .near(
                 [lat, lng], radius_km,
                 units: :km,
                 latitude: "application_versions.lat",
                 longitude: "application_versions.lng"
               )
               .where("first_date_scraped > ?", cutoff_time)
  end

  # Applications in the area of interest which have new comments made since we were last alerted
  sig { returns(T.untyped) }
  def applications_with_new_comments
    Application.with_current_version
               .order("date_scraped DESC")
               .near(
                 [lat, lng], radius_km,
                 units: :km,
                 latitude: "application_versions.lat",
                 longitude: "application_versions.lng"
               )
               .joins(:comments)
               .where("comments.confirmed_at > ?", cutoff_time)
               .where("comments.confirmed" => true)
               .where("comments.hidden" => false)
               .distinct
  end

  sig { returns(T::Array[Comment]) }
  def new_comments
    comments = T.let([], T::Array[Comment])
    # Doing this in this roundabout way because I'm not sure how to use "near" together with joins
    applications_with_new_comments.each do |application|
      comments += application.comments.visible.where("comments.confirmed_at > ?", cutoff_time)
    end
    comments
  end

  sig { returns(T.any(ActiveSupport::TimeWithZone, Date)) }
  def cutoff_time
    last_sent || Date.yesterday
  end

  sig { returns(Float) }
  def radius_km
    radius_meters / 1000.0
  end

  sig { void }
  def confirm!
    update!(confirmed: true)
  end

  sig { void }
  def geocode_from_address
    @geocode_result = T.let(GoogleGeocodeService.call(address), T.nilable(GeocoderResults))

    r = T.must(@geocode_result)
    top = r.top
    return if top.nil? || r.all.many?

    self.location = top
    self.address = top.full_address
  end

  private

  sig { void }
  def validate_address
    # Only validate the street address if we used the geocoder
    return unless @geocode_result

    top = @geocode_result.top
    error = @geocode_result.error
    if top.nil?
      errors.add(:address, error) if error
    elsif @geocode_result.all.many?
      errors.add(:address, "isn't complete. Please enter a full street address, including suburb and state, e.g. #{top.full_address}")
    end
  end

  sig { void }
  def set_confirm_info
    # TODO: Should check that this is unique across all objects and if not try again
    self.confirm_id = Digest::MD5.hexdigest(Kernel.rand.to_s + Time.zone.now.to_s)[0...20]
  end
end
