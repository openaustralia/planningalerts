# typed: strict
# frozen_string_literal: true

class Authority < ApplicationRecord
  extend T::Sig

  has_many :applications, dependent: :restrict_with_exception
  has_many :comments, through: :applications
  has_one :github_issue, dependent: :destroy

  validate :short_name_encoded_is_unique

  validates :state, inclusion: {
    in: %w[NSW VIC QLD SA WA TAS NT ACT],
    message: "%<value> is not a state in Australia"
  }

  scope(:enabled, -> { where("disabled = 0 or disabled is null") })
  scope(:active, -> { where('(disabled = 0 or disabled is null) AND morph_name != "" AND morph_name IS NOT NULL') })

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

  # Hardcoded total population of Australia (2017 estimate)
  # From http://stat.data.abs.gov.au/Index.aspx?DataSetCode=ABS_ERP_LGA2017
  sig { returns(Integer) }
  def self.total_population_2017
    24597528
  end

  sig { returns(Integer) }
  def self.total_population_2017_covered_by_all_active_authorities
    sum = 0
    Authority.active.each do |a|
      population = a.population_2017
      sum += population if population
    end
    sum
  end

  sig { returns(Float) }
  def self.percentage_population_covered_by_all_active_authorities
    (total_population_2017_covered_by_all_active_authorities.to_f / total_population_2017) * 100
  end

  # Returns an array of arrays [date, number_of_applications_that_date]
  sig { returns(T::Array[T::Array[[Date, Integer]]]) }
  def new_applications_per_day
    h = applications.with_first_version.order("date_scraped DESC").group("CAST(date_scraped AS DATE)").count
    # For any dates not in h fill them in with zeros
    (h.keys.min..Time.zone.today).each do |date|
      h[date] = 0 unless h.key?(date)
    end
    h.sort
  end

  sig { returns(T.nilable(Integer)) }
  def median_new_applications_per_week
    v = new_applications_per_week.select { |a| a[1].positive? }.map { |a| a[1] }.sort
    v[v.count / 2]
  end

  sig { returns(T::Array[[Date, Integer]]) }
  def new_applications_per_week
    # Sunday is the beginning of the week (and the date returned here)
    # Have to compensate for MySQL which treats Monday as the beginning of the week
    h = applications.with_first_version.order("date_scraped DESC").group("CAST(SUBDATE(date_scraped, WEEKDAY(date_scraped) + 1) AS DATE)").count
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
      # Have to compensate for MySQL which treats Monday as the beginning of the week
      results = comments.visible.group(
        "CAST(SUBDATE(confirmed_at, WEEKDAY(confirmed_at) + 1) AS DATE)"
      ).count

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
    earliest_application = applications.with_first_version.order("date_scraped").first
    earliest_application&.first_date_scraped
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
    latest_application = applications.with_first_version.order("date_scraped DESC").first
    latest_application&.first_date_scraped
  end

  # If the latest application is over two weeks old, the scraper's probably broken
  sig { returns(T::Boolean) }
  def broken?
    applications.recent.empty?
  end
end
