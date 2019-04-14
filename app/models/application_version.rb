# frozen_string_literal: true

class ApplicationVersion < ApplicationRecord
  belongs_to :application
  belongs_to :previous_version, class_name: "ApplicationVersion", optional: true

  validates :date_scraped, :address, :description, presence: true
  validates :info_url, url: true
  validates :comment_url, url: { allow_blank: true, schemes: %w[http https mailto] }
  validate :date_received_can_not_be_in_the_future, :validate_on_notice_period

  validates :current, uniqueness: { scope: :application_id }, if: :current

  before_save :geocode

  delegate :authority, :council_reference, to: :application

  # TODO: factor out common location accessor between Application and Alert
  def location
    Location.new(lat: lat, lng: lng) if lat && lng
  end

  private

  def date_received_can_not_be_in_the_future
    return unless date_received && date_received > Time.zone.today

    errors.add(:date_received, "can not be in the future")
  end

  def validate_on_notice_period
    return unless on_notice_from || on_notice_to

    if on_notice_from.nil?
      # errors.add(:on_notice_from, "can not be empty if end of on notice period is set")
    elsif on_notice_to.nil?
      # errors.add(:on_notice_to, "can not be empty if start of on notice period is set")
    elsif on_notice_from > on_notice_to
      errors.add(:on_notice_to, "can not be earlier than the start of the on notice period")
    end
  end

  # TODO: Optimisation is to make sure that this doesn't get called again on save when the address hasn't changed
  def geocode
    # Only geocode if location hasn't been set
    return if lat && lng && suburb && state && postcode

    r = GeocodeService.call(address)
    if r.error.nil?
      self.lat = r.top.lat
      self.lng = r.top.lng
      self.suburb = r.top.suburb
      self.state = r.top.state
      # Hack - workaround for inconsistent returned state name (as of 21 Jan 2011)
      # from Google Geocoder
      self.state = "NSW" if state == "New South Wales"
      self.postcode = r.top.postcode
    else
      logger.error "Couldn't geocode address: #{address} (#{r.error})"
    end
    application.make_dirty!
  end
end
