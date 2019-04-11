# frozen_string_literal: true

require "open-uri"

class Application < ApplicationRecord
  ATTRIBUTE_KEYS_FOR_VERSIONS = %w[
    date_scraped
    address
    description
    info_url
    comment_url
    date_received
    on_notice_from
    on_notice_to
    lat
    lng
    suburb
    state
    postcode
  ].freeze

  searchkick highlight: [:description],
             index_name: "pa_applications_#{ENV['STAGE']}",
             locations: [:location],
             callbacks: :async

  belongs_to :authority
  has_many :comments, dependent: :restrict_with_exception
  has_many :replies, through: :comments
  has_many :versions, -> { order(id: :desc) }, class_name: "ApplicationVersion", dependent: :restrict_with_exception, inverse_of: :application
  has_one :current_version, -> { where(current: true) }, class_name: "ApplicationVersion", inverse_of: :application

  before_save :geocode
  geocoded_by :address, latitude: :lat, longitude: :lng

  validates :date_scraped, :council_reference, :address, :description, presence: true
  validates :info_url, url: true
  validates :comment_url, url: { allow_blank: true, schemes: %w[http https mailto] }
  validate :date_received_can_not_be_in_the_future, :validate_on_notice_period
  validates :council_reference, uniqueness: { scope: :authority_id }

  scope(:with_current_version, -> { includes(:current_version).joins(:current_version) })
  scope(:in_past_week, -> { joins(:current_version).where("application_versions.date_scraped > ?", 7.days.ago) })
  scope(:recent, -> { joins(:current_version).where("application_versions.date_scraped >= ?", 14.days.ago) })

  # TODO: Temporarily commenting out to get test to run
  # Note that search isn't working currently with the versioning
  # TODO: Make it work again :-)
  # def search_data
  #   attributes.merge(location: { lat: lat, lon: lng })
  # end

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

  # For the benefit of will_paginate
  cattr_reader :per_page
  # rubocop:disable Style/ClassVars
  @@per_page = 100
  # rubocop:enable Style/ClassVars

  delegate :location, to: :current_version

  def date_scraped
    load_version_data
    @date_scraped
  end

  def info_url
    load_version_data
    @info_url
  end

  def comment_url
    load_version_data
    @comment_url
  end

  def date_received
    load_version_data
    @date_received
  end

  def on_notice_from
    load_version_data
    @on_notice_from
  end

  def on_notice_to
    load_version_data
    @on_notice_to
  end

  def lat
    load_version_data
    @lat
  end

  def lng
    load_version_data
    @lng
  end

  def suburb
    load_version_data
    @suburb
  end

  def state
    load_version_data
    @state
  end

  def postcode
    load_version_data
    @postcode
  end

  def description
    load_version_data
    description = @description
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

  def address
    load_version_data
    address = @address
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

  def date_scraped=(value)
    load_version_data
    @date_scraped = value
  end

  def info_url=(value)
    load_version_data
    @info_url = value
  end

  def comment_url=(value)
    load_version_data
    @comment_url = value
  end

  def date_received=(value)
    load_version_data
    @date_received = value
  end

  def on_notice_from=(value)
    load_version_data
    @on_notice_from = value
  end

  def on_notice_to=(value)
    load_version_data
    @on_notice_to = value
  end

  def lat=(value)
    load_version_data
    @lat = value
  end

  def lng=(value)
    load_version_data
    @lng = value
  end

  def suburb=(value)
    load_version_data
    @suburb = value
  end

  def state=(value)
    load_version_data
    @state = value
  end

  def postcode=(value)
    load_version_data
    @postcode = value
  end

  def description=(value)
    load_version_data
    @description = value
  end

  def address=(value)
    load_version_data
    @address = value
  end

  # Default values for what we consider nearby and recent
  def nearby_and_recent_max_distance_km
    Application.nearby_and_recent_max_distance_km
  end

  # Default values for what we consider nearby and recent
  def nearby_and_recent_max_age_months
    Application.nearby_and_recent_max_age_months
  end

  def self.nearby_and_recent_max_distance_km
    2
  end

  def self.nearby_and_recent_max_age_months
    2
  end

  # Find applications that are near the current application location and/or recently scraped
  def find_all_nearest_or_recent
    if location
      nearbys(
        nearby_and_recent_max_distance_km,
        units: :km,
        latitude: "application_versions.lat",
        longitude: "application_versions.lng"
      ).with_current_version.where("application_versions.date_scraped > ?", nearby_and_recent_max_age_months.months.ago)
    else
      []
    end
  end

  def official_submission_period_expired?
    on_notice_to && Time.zone.today > on_notice_to
  end

  def current_councillors_for_authority
    authority.councillors.where(current: true).shuffle if authority.councillors.any?
  end

  def councillors_available_for_contact
    current_councillors_for_authority if authority.write_to_councillors_enabled?
  end

  def create_version
    @version_data_loaded = true
    # If none of the data has changed don't save a new version
    return if current_version && attributes_for_version_data == current_version.attributes.slice(*ATTRIBUTE_KEYS_FOR_VERSIONS)

    current_version&.update(current: false)
    versions.create!(attributes_for_version_data.merge(previous_version: current_version, current: true))
    reload_current_version
  end

  private

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

  def attributes_for_version_data
    r = {}
    ATTRIBUTE_KEYS_FOR_VERSIONS.each do |attribute_key|
      r[attribute_key] = send(attribute_key)
    end
    r
  end

  def load_version_data
    return if @version_data_loaded || !persisted?

    ATTRIBUTE_KEYS_FOR_VERSIONS.each do |attribute_key|
      instance_variable_set("@#{attribute_key}", current_version.send(attribute_key))
    end
    @version_data_loaded = true
  end
end
