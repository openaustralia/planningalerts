# frozen_string_literal: true

require "open-uri"

class AuthorityLogger < Logger
  def initialize(authority, other_logger)
    @authority = authority
    @other_logger = other_logger
    # We're starting a new run of the logger & scraper so clear out the old so we're ready for the new
    @authority.update_attribute(:last_scraper_run_log, "")
  end

  def add(severity, message = nil, progname = nil)
    @other_logger.add(severity, message, progname)
    # Put a maximum limit on how long the log can get
    e = @authority.last_scraper_run_log + progname + "\n"
    return if e.size >= 5000

    @authority.update_column(:last_scraper_run_log, e)
  end
end

class Authority < ActiveRecord::Base
  has_many :applications
  has_many :councillors
  has_many :comments, through: :applications
  has_many :councillor_contributions

  validates :short_name, presence: true, uniqueness: { case_sensitive: false }

  validates :state, inclusion: {
    in: %w[NSW VIC QLD SA WA TAS NT ACT],
    message: "%{value} is not a state in Australia"
  }

  scope :enabled, -> { where("disabled = 0 or disabled is null") }
  scope :active, -> { where('(disabled = 0 or disabled is null) AND morph_name != "" AND morph_name IS NOT NULL') }

  def full_name_and_state
    full_name + ", " + state
  end

  def covered?
    !morph_name.blank?
  end

  # Hardcoded total population of Australia (2011 estimate)
  # From http://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/3218.02011?OpenDocument#Data
  def self.total_population_2011
    22323933
  end

  def self.nsw_total_population_2011
    7211468
  end

  def self.nsw_total_population_covered_by_all_active_authorities
    sum = 0
    Authority.where(state: "NSW").active.each do |a|
      sum += a.population_2011 if a.population_2011
    end
    sum
  end

  def self.total_population_covered_by_all_active_authorities
    sum = 0
    Authority.active.each do |a|
      sum += a.population_2011 if a.population_2011
    end
    sum
  end

  def self.percentage_population_covered_by_all_active_authorities
    (total_population_covered_by_all_active_authorities.to_f / total_population_2011) * 100
  end

  def self.nsw_percentage_population_covered_by_all_active_authorities
    (nsw_total_population_covered_by_all_active_authorities.to_f / nsw_total_population_2011) * 100
  end

  # Open a url and return it's content. If there is a problem will just return nil rather than raising an exception
  def open_url_safe(url, info_logger, options = {})
    open(url, options).read
  rescue StandardError => e
    info_logger.error "Error #{e} while getting data from url #{url}. So, skipping"
    nil
  end

  # Get all the scraper data for this authority and date in an array of attributes that can be used
  # creating applications
  def scraper_data_original_style(feed_url, info_logger)
    feed_data = []
    text = open_url_safe(feed_url, info_logger)

    feed_data += Application.translate_feed_data(text) if text
    feed_data
  end

  def scraper_data_morph_style(start_date, end_date, info_logger)
    text = open_url_safe(morph_feed_url_for_date_range(start_date, end_date), info_logger)
    if text
      Application.translate_morph_feed_data(text)
    else
      []
    end
  end

  # Collect applications over the default date range
  def collect_applications(other_info_logger = logger)
    # Also log to the authority database as well so we have easy access to this for the user
    info_logger = AuthorityLogger.new(self, other_info_logger)

    time = Benchmark.ms do
      collect_applications_date_range(Date.today - ENV["SCRAPE_DELAY"].to_i, Date.today, info_logger)
    end
    info_logger.info "Took #{(time / 1000).to_i} s to collect applications from #{full_name_and_state}"
  end

  # Same as collection_applications_data_range except the applications are returned rather than saved
  def collect_unsaved_applications_date_range(start_date, end_date, info_logger = logger)
    d = scraper_data_morph_style(start_date, end_date, info_logger)
    d.map do |attributes|
      applications.build(attributes)
    end
  end

  def collect_unsaved_applications_date_range_original_style(feed_url, info_logger = logger)
    d = scraper_data_original_style(feed_url, info_logger)
    d.map do |attributes|
      applications.build(attributes)
    end
  end

  # Collect all the applications for this authority by scraping
  def collect_applications_date_range(start_date, end_date, info_logger = logger)
    count = 0
    error_count = 0
    collect_unsaved_applications_date_range(start_date, end_date, info_logger).each do |application|
      # TODO: Consider if it would be better to overwrite applications with new data if they already exists
      # This would allow for the possibility that the application information was incorrectly entered at source
      # and was updated. But we would have to think whether those updated applications should get mailed out, etc...
      next if applications.find_by_council_reference(application.council_reference)

      begin
        application.save!
        count += 1
      rescue StandardError => e
        error_count += 1
        info_logger.error "Error #{e} while trying to save application #{application.council_reference} for #{full_name_and_state}. So, skipping"
      end
    end

    info_logger.info "#{count} new applications found for #{full_name_and_state} with date from #{start_date} to #{end_date}"
    return if error_count.zero?

    info_logger.info "#{error_count} applications errored for #{full_name_and_state} with date from #{start_date} to #{end_date}"
  end

  # Returns an array of arrays [date, number_of_applications_that_date]
  def applications_per_day
    h = applications.group("CAST(date_scraped AS DATE)").count
    # For any dates not in h fill them in with zeros
    (h.keys.min..Date.today).each do |date|
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
    max = Date.today - Date.today.wday
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
      latest_week = Date.today.at_beginning_of_week

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

  def morph_url
    "https://morph.io/#{morph_name}" unless morph_name.blank?
  end

  def morph_feed_url_for_date_range(start_date, end_date)
    query = CGI.escape("select * from `data` where `date_scraped` >= '#{start_date}' and `date_scraped` <= '#{end_date}'")
    "https://api.morph.io/#{morph_name}/data.json?query=#{query}&key=#{ENV['MORPH_API_KEY']}"
  end

  # So that the encoding function can be used elsewhere
  def self.short_name_encoded(short_name)
    short_name.downcase.tr(" ", "_").gsub(/\W/, "")
  end

  def short_name_encoded
    Authority.short_name_encoded(short_name)
  end

  def self.find_by_short_name_encoded(n)
    # TODO: Potentially not very efficient when number of authorities is high. Loads all authorities into memory
    all.find { |a| a.short_name_encoded == n }
  end

  def self.find_by_short_name_encoded!(n)
    r = find_by_short_name_encoded(n)
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

      no_longer_councillor = person.end_date.present? && Date.parse(person.end_date) <= Date.today

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
