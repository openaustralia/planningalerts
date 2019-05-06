# frozen_string_literal: true

class ApplicationVersion < ApplicationRecord
  belongs_to :application
  belongs_to :previous_version, class_name: "ApplicationVersion", optional: true

  validates :date_scraped, :address, :description, presence: true
  validates :info_url, url: true
  validate :date_received_can_not_be_in_the_future, :validate_on_notice_period

  validates :current, uniqueness: { scope: :application_id }, if: :current

  before_save :geocode

  delegate :authority, :council_reference, to: :application

  def search_data
    attributes.merge(location: { lat: lat, lon: lng })
  end

  def description
    ApplicationVersion.normalise_description(self[:description])
  end

  def address
    ApplicationVersion.normalise_address(self[:address])
  end

  # TODO: factor out common location accessor between Application and Alert
  def location
    Location.new(lat: lat, lng: lng) if lat && lng
  end

  def data_attributes
    attributes.except(
      "id", "created_at", "updated_at", "application_id",
      "previous_version_id", "current"
    )
  end

  def self.create_version!(application_id:, previous_version:, attributes:)
    create!(
      (previous_version&.data_attributes || {})
        .merge(attributes)
        .merge(
          "application_id" => application_id,
          "previous_version_id" => previous_version&.id,
          "current" => true
        )
    )
  end

  def self.normalise_description(description)
    return unless description

    # If whole description is in upper case switch the whole description to lower case
    description = description.downcase if description.upcase == description
    description.split(". ").map do |sentence|
      words = sentence.split(" ")
      # Capitalise the first word of the sentence if it's all lowercase
      words[0] = words[0].capitalize if !words[0].nil? && words[0].downcase == words[0]
      words.join(" ")
    end.join(". ")
  end

  def self.normalise_address(address)
    return unless address

    exceptions = %w[QLD VIC NSW SA ACT TAS WA NT]

    address.split(" ").map do |word|
      if word != word.upcase || exceptions.any? { |exception| word =~ /^\W*#{exception}\W*$/ } || word =~ /\d/
        word
      else
        word.capitalize
      end
    end.join(" ")
  end

  def official_submission_period_expired?
    on_notice_to && Time.zone.today > on_notice_to
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
  end
end
