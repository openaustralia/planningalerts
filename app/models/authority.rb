# frozen_string_literal: true

class Authority < ApplicationRecord
  has_many :applications, dependent: :restrict_with_exception
  has_many :councillors, dependent: :restrict_with_exception
  has_many :comments, through: :applications
  has_many :councillor_contributions, dependent: :restrict_with_exception

  validates :short_name, presence: true, uniqueness: { case_sensitive: false }

  validates :state, inclusion: {
    in: %w[NSW VIC QLD SA WA TAS NT ACT],
    message: "%{value} is not a state in Australia"
  }

  scope(:enabled, -> { where("disabled = 0 or disabled is null") })
  scope(:active, -> { where('(disabled = 0 or disabled is null) AND morph_name != "" AND morph_name IS NOT NULL') })

  def full_name_and_state
    full_name + ", " + state
  end

  def covered?
    morph_name.present?
  end

  # Hardcoded total population of Australia (2017 estimate)
  # From http://stat.data.abs.gov.au/Index.aspx?DataSetCode=ABS_ERP_LGA2017
  def self.total_population_2017
    24597528
  end

  def self.total_population_2017_covered_by_all_active_authorities
    sum = 0
    Authority.active.each do |a|
      sum += a.population_2017 if a.population_2017
    end
    sum
  end

  def self.percentage_population_covered_by_all_active_authorities
    (total_population_2017_covered_by_all_active_authorities.to_f / total_population_2017) * 100
  end

  # Returns an array of arrays [date, number_of_applications_that_date]
  def applications_per_day
    h = applications.group("CAST(date_scraped AS DATE)").count
    # For any dates not in h fill them in with zeros
    (h.keys.min..Time.zone.today).each do |date|
      h[date] = 0 unless h.key?(date)
    end
    h.sort
  end

  def median_applications_per_week
    v = applications_per_week.select { |a| a[1].positive? }.map { |a| a[1] }.sort
    v[v.count / 2]
  end

  def applications_per_week
    # Sunday is the beginning of the week (and the date returned here)
    # Have to compensate for MySQL which treats Monday as the beginning of the week
    h = applications.group("CAST(SUBDATE(date_scraped, WEEKDAY(date_scraped) + 1) AS DATE)").count
    min = h.keys.min
    max = Time.zone.today - Time.zone.today.wday
    (min..max).step(7) do |date|
      h[date] = 0 unless h.key?(date)
    end
    h.sort
  end

  def comments_per_week
    # Sunday is the beginning of the week to match applications_per_week
    Date.beginning_of_week = :sunday

    results = []

    if applications.any?
      # Have to compensate for MySQL which treats Monday as the beginning of the week
      results = comments.visible.group(
        "CAST(SUBDATE(confirmed_at, WEEKDAY(confirmed_at) + 1) AS DATE)"
      ).count

      earliest_week_with_applications = earliest_date.at_beginning_of_week.to_date
      latest_week = Time.zone.today.at_beginning_of_week

      (earliest_week_with_applications..latest_week).step(7) do |date|
        results[date] = 0 unless results.key?(date)
      end
    end

    results.sort
  end

  # When this authority started on PlanningAlerts. Just the date of the earliest scraped application
  def earliest_date
    # Removing default scoping by using "unscoped". Hmmm. Maybe get rid of default scoping entirely?
    earliest_application = Application.unscoped do
      applications.order("date_scraped").first
    end
    earliest_application&.date_scraped
  end

  # So that the encoding function can be used elsewhere
  def self.short_name_encoded(short_name)
    short_name.downcase.tr(" ", "_").gsub(/\W/, "")
  end

  def short_name_encoded
    Authority.short_name_encoded(short_name)
  end

  def self.find_short_name_encoded(name)
    # TODO: Potentially not very efficient when number of authorities is high. Loads all authorities into memory
    all.find { |a| a.short_name_encoded == name }
  end

  def self.find_short_name_encoded!(name)
    r = find_short_name_encoded(name)
    # In production environment raising RecordNotFound will produce an error code 404
    raise ActiveRecord::RecordNotFound if r.nil?

    r
  end

  # Is this authority contactable through PlanningAlerts? i.e. do we have an email address on record?
  # TODO: The authority should be contactable if there are councillors to contact
  #       even if there is no official contact email
  def contactable?
    email && email != ""
  end

  def write_to_councillors_enabled?
    ENV["COUNCILLORS_ENABLED"] == "true" ? write_to_councillors_enabled : false
  end

  def load_councillors(popolo)
    popolo_councillors = PopoloCouncillors.new(popolo)
    persons = popolo_councillors.for_authority(full_name)

    persons.map do |person|
      councillor = councillors.find_or_create_by(name: person.name)

      no_longer_councillor = person.end_date.present? && Date.parse(person.end_date) <= Time.zone.today

      councillor.current = false if no_longer_councillor
      councillor.popolo_id = person.id
      councillor.image_url = councillor.cached_image_url if councillor.cached_image_available?
      councillor.update(email: person.email, party: person.party)

      councillor
    end
  end

  def popolo_url
    "https://raw.githubusercontent.com/openaustralia/australian_local_councillors_popolo/master/data/#{state.upcase}/local_councillor_popolo.json"
  end

  def latest_application
    # The applications are sorted by default by the date_scraped because of the default scope on the model
    applications.first
  end

  def latest_application_date
    latest_application&.date_scraped
  end

  # If the latest application is over two weeks old, the scraper's probably broken
  def broken?
    applications.recent.empty?
  end
end
