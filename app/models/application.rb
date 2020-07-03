# typed: strict
# frozen_string_literal: true

class Application < ApplicationRecord
  extend T::Sig

  searchkick highlight: [:description],
             index_name: "pa_applications_#{ENV['STAGE']}",
             locations: [:location],
             callbacks: :async

  belongs_to :authority
  has_many :comments, dependent: :restrict_with_exception
  has_many :replies, through: :comments
  has_many :versions, -> { order(id: :desc) }, class_name: "ApplicationVersion", dependent: :restrict_with_exception, inverse_of: :application
  has_one :current_version, -> { where(current: true) }, class_name: "ApplicationVersion", inverse_of: :application
  has_one :first_version, -> { where(previous_version: nil) }, class_name: "ApplicationVersion", inverse_of: :application

  geocoded_by :address, latitude: :lat, longitude: :lng

  validates :council_reference, presence: true
  validates :council_reference, uniqueness: { scope: :authority_id }

  scope(:with_current_version, -> { includes(:current_version).joins(:current_version) })
  scope(:with_first_version, -> { includes(:first_version).joins(:first_version) })
  scope(:in_past_week, -> { joins(:current_version).where("date_scraped > ?", 7.days.ago) })
  scope(:recent, -> { joins(:current_version).where("date_scraped >= ?", 14.days.ago) })

  sig { returns(T::Hash[String, T.untyped]) }
  def search_data
    # Include version data in what's indexed by searchkick
    attributes.merge(current_version&.search_data || {})
  end

  # For the benefit of will_paginate
  cattr_reader :per_page
  # rubocop:disable Style/ClassVars
  @@per_page = T.let(100, Integer)
  # rubocop:enable Style/ClassVars

  delegate :info_url, :date_received,
           :on_notice_from, :on_notice_to, :lat, :lng, :suburb, :state,
           :postcode, :description, :address, :location,
           :official_submission_period_expired?,
           to: :current_version

  # TODO: Give this (date_scraped) a more sensible name
  delegate :date_scraped, to: :first_version

  delegate :councillors_available_for_contact, to: :authority

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
  sig { returns(Application::ActiveRecord_Relation) }
  def find_all_nearest_or_recent
    if location
      nearbys(
        Application.nearby_and_recent_max_distance_km,
        units: :km,
        latitude: "application_versions.lat",
        longitude: "application_versions.lng"
      ).with_current_version.where("date_scraped > ?", Application.nearby_and_recent_max_age_months.months.ago)
    else
      []
    end
  end
end
