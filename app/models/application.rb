# frozen_string_literal: true

require "open-uri"

class Application < ApplicationRecord
  searchkick highlight: [:description],
             index_name: "pa_applications_#{ENV['STAGE']}",
             locations: [:location],
             callbacks: :async

  belongs_to :authority
  has_many :comments, dependent: :restrict_with_exception
  has_many :replies, through: :comments
  has_many :versions, -> { order(id: :desc) }, class_name: "ApplicationVersion", dependent: :restrict_with_exception, inverse_of: :application
  has_one :current_version, -> { where(current: true) }, class_name: "ApplicationVersion", inverse_of: :application

  geocoded_by :address, latitude: :lat, longitude: :lng

  validates :council_reference, presence: true
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

  # For the benefit of will_paginate
  cattr_reader :per_page
  # rubocop:disable Style/ClassVars
  @@per_page = 100
  # rubocop:enable Style/ClassVars

  delegate :date_scraped, :info_url, :comment_url, :date_received,
           :on_notice_from, :on_notice_to, :lat, :lng, :suburb, :state,
           :postcode, :description, :address, :location,
           to: :current_version

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

  def create_version(attributes)
    # If none of the data has changed don't save a new version
    return if current_version && attributes == current_version.attributes.symbolize_keys.slice(*attributes.keys)

    current_version&.update(current: false)
    current_attributes = current_version&.attributes || {}
    current_attributes = current_attributes.symbolize_keys
    current_attributes.delete(:id)
    current_attributes.delete(:created_at)
    current_attributes.delete(:updated_at)
    versions.create!(current_attributes.merge(attributes).merge(previous_version: current_version, current: true))
    reload_current_version
  end
end
