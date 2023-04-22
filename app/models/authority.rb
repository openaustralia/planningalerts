# typed: strict
# frozen_string_literal: true

class Authority < ApplicationRecord
  extend T::Sig

  has_many :applications, dependent: :restrict_with_exception
  has_many :comments, through: :applications
  has_one :github_issue, dependent: :destroy

  validate :short_name_encoded_is_unique

  validates :state, inclusion: { in: %w[NSW VIC QLD SA WA TAS NT ACT] }

  scope(:enabled, -> { where(disabled: false) })
  scope(:active, -> { where(disabled: false).where("morph_name != '' AND morph_name IS NOT NULL") })

  sig { void }
  def short_name_encoded_is_unique
    other = Authority.find_short_name_encoded(short_name_encoded)
    return if other.nil? || other.id == id

    errors.add(:short_name, "is not unique when encoded")
  end

  sig { returns(String) }
  def full_name_and_state
    "#{full_name}, #{state}"
  end

  sig { returns(T::Boolean) }
  def covered?
    morph_name.present?
  end

  # Total population of Australia based on the 2021 Census
  # https://www.abs.gov.au/statistics/people/population/population-census/2021
  sig { returns(Integer) }
  def self.total_population_2021
    25422788
  end

  sig { returns(Integer) }
  def self.total_population_2021_covered_by_all_active_authorities
    sum = 0
    Authority.active.each do |a|
      population = a.population_2021
      sum += population if population
    end
    sum
  end

  sig { returns(Float) }
  def self.percentage_population_covered_by_all_active_authorities
    (total_population_2021_covered_by_all_active_authorities.to_f / total_population_2021) * 100
  end

  sig { returns(T.nilable(Integer)) }
  def median_new_applications_per_week
    v = new_applications_per_week.select { |a| a[1].positive? }.pluck(1).sort
    v[v.count / 2]
  end

  sig { returns(T::Array[[Date, Integer]]) }
  def new_applications_per_week
    # Sunday is the beginning of the week (and the date returned here)
    h = applications.group("DATE(first_date_scraped) - CAST(EXTRACT(DOW FROM first_date_scraped) AS INT)").count
    min = h.keys.min
    max = Time.zone.today - Time.zone.today.wday
    (min..max).step(7) do |date|
      h[date] = 0 unless h.key?(date)
    end
    h.sort
  end

  # TODO: More strict type checking on contents of array
  sig { returns(T::Array[[Date, Integer]]) }
  def comments_per_week
    # Sunday is the beginning of the week to match new_applications_per_week
    Date.beginning_of_week = :sunday

    results = []

    e = earliest_date
    if e
      results = comments.visible.group("DATE(confirmed_at) - CAST(EXTRACT(DOW FROM confirmed_at) AS INT)").count

      earliest_week_with_applications = e.at_beginning_of_week.to_date
      latest_week = Time.zone.today.at_beginning_of_week

      (earliest_week_with_applications..latest_week).step(7) do |date|
        results[date] = 0 unless results.key?(date)
      end
    end

    results.sort
  end

  # When this authority started on PlanningAlerts. Just the date of the earliest scraped application
  sig { returns(T.nilable(Time)) }
  def earliest_date
    applications.minimum(:first_date_scraped)
  end

  # So that the encoding function can be used elsewhere
  sig { params(short_name: String).returns(String) }
  def self.short_name_encoded(short_name)
    short_name.downcase.tr(" ", "_").gsub(/\W/, "")
  end

  sig { returns(String) }
  def short_name_encoded
    Authority.short_name_encoded(short_name)
  end

  sig { params(name: String).returns(T.nilable(Authority)) }
  def self.find_short_name_encoded(name)
    # TODO: Potentially not very efficient when number of authorities is high. Loads all authorities into memory
    all.to_a.find { |a| a.short_name_encoded == name }
  end

  sig { params(name: String).returns(Authority) }
  def self.find_short_name_encoded!(name)
    r = find_short_name_encoded(name)
    # In production environment raising RecordNotFound will produce an error code 404
    raise ActiveRecord::RecordNotFound if r.nil?

    r
  end

  # When the last entirely new application was scraped. Applications being updated is ignored.
  sig { returns(T.nilable(Time)) }
  def date_last_new_application_scraped
    applications.maximum(:first_date_scraped)
  end

  # If the latest application is over two weeks old, the scraper's probably broken
  sig { returns(T::Boolean) }
  def broken?
    applications.recent.empty?
  end

  sig { returns(ActiveRecord::Relation) }
  def alerts
    Alert.active.where("ST_Covers(?, lonlat)", boundary.to_s)
  end
end
