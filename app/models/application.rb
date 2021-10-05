# typed: strict
# frozen_string_literal: true

require "geocoder/stores/active_record"

class Application < ApplicationRecord
  extend T::Sig

  # For sorbet
  include Geocoder::Store::ActiveRecord
  extend Geocoder::Model::ActiveRecord
  extend Kaminari::ConfigurationMethods::ClassMethods

  searchkick highlight: [:description],
             index_name: "pa_applications_#{ENV['STAGE']}",
             locations: [:location],
             callbacks: :async

  belongs_to :authority
  has_many :comments, dependent: :restrict_with_exception
  has_many :versions, -> { order(id: :desc) }, class_name: "ApplicationVersion", dependent: :destroy, inverse_of: :application
  has_one :current_version, -> { where(current: true) }, class_name: "ApplicationVersion", inverse_of: :application
  # TODO: Move first_date_scraped into applications table so that we don't need this association
  has_one :first_version, -> { where(previous_version: nil) }, class_name: "ApplicationVersion", inverse_of: :application

  geocoded_by :address, latitude: :lat, longitude: :lng

  validates :council_reference, presence: true
  validates :council_reference, uniqueness: { scope: :authority_id, case_sensitive: false }

  scope(:with_current_version, -> { includes(:current_version).joins(:current_version) })
  scope(:with_first_version, -> { includes(:first_version).joins(:first_version) })
  scope(:in_past_week, -> { joins(:first_version).where("date_scraped > ?", 7.days.ago) })
  scope(:recent, -> { joins(:first_version).where("date_scraped >= ?", 14.days.ago) })

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def search_data
    # Include version data in what's indexed by searchkick
    attributes.symbolize_keys.merge(current_version&.search_data || {})
  end

  # For the benefit of kaminari. Also sets the maximum number of
  # allowed returned applications in a single API request
  max_paginates_per 100

  delegate :info_url, :date_received,
           :on_notice_from, :on_notice_to, :lat, :lng, :suburb, :state,
           :postcode, :description, :address, :location,
           :official_submission_period_expired?, :date_scraped,
           to: :current_version

  sig { returns(Time) }
  def first_date_scraped
    T.must(first_version).date_scraped.time
  end

  # Providing this for back compatibility in the API
  sig { returns(NilClass) }
  def comment_url
    nil
  end

  # Default values for what we consider nearby and recent
  sig { returns(Integer) }
  def self.nearby_and_recent_max_distance_km
    2
  end

  # Default values for what we consider nearby and recent
  sig { returns(Integer) }
  def self.nearby_and_recent_max_age_months
    2
  end

  # Find applications that are near the current application location and/or recently scraped
  sig { returns(T.untyped) }
  def find_all_nearest_or_recent
    if location
      nearbys(
        Application.nearby_and_recent_max_distance_km,
        units: :km,
        latitude: "current_versions_applications.lat",
        longitude: "current_versions_applications.lng"
      ).with_first_version.with_current_version.where("application_versions.date_scraped > ?", Application.nearby_and_recent_max_age_months.months.ago)
    else
      Application.none
    end
  end
end
