require 'open-uri'

class Authority < ActiveRecord::Base
  has_many :applications
  scope :active, :conditions => 'disabled = 0 or disabled is null'
  
  def full_name_and_state
    full_name + ", " + state
  end
  
  def self.load_from_web_service(info_logger = logger)
    page = Nokogiri::XML(open(::Configuration::INTERNAL_SCRAPERS_INDEX_URL).read)
    page.search('scraper').each do |scraper|
      short_name = scraper.at('authority_short_name').inner_text
      authority = Authority.find_by_short_name(short_name)
      if authority.nil?
        info_logger.info "New authority: #{short_name}"
        authority = Authority.new(:short_name => short_name)
      else
        info_logger.info "Updating authority: #{short_name}"
      end
      authority.full_name = scraper.at('authority_name').inner_text
      authority.state = scraper.at('state').inner_text
      authority.scraperwiki_name = scraper.at('scraperwiki_name').inner_text
      authority.feed_url = scraper.at('url').inner_text
      authority.disabled = 0

      authority.save!
    end
  end

  # Hardcoded total population of Australia (2011 estimate)
  # From http://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/3218.02011?OpenDocument#Data
  def self.total_population_2011
    22323933
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

  # Get all the scraper data for this authority and date in an array of attributes that can be used
  # creating applications
  def scraper_data(date, info_logger = logger)
    url = scraperwiki? ? scraperwiki_feed_url_for_date(date) : feed_url_for_date(date)

    begin
      feed_data = open(url).read
    rescue Exception => e
      info_logger.error "Error #{e} while getting data from url #{url}. So, skipping"
      return []
    end

    scraperwiki? ? Application.translate_scraperwiki_feed_data(feed_data) : Application.translate_feed_data(feed_data)
  end

  def scraper_data_original_style(start_date, end_date, info_logger)
    feed_data = []
    # Go through the dates in reverse chronological order
    (start_date..end_date).to_a.reverse.each do |date|
      feed_data += scraper_data(date, info_logger)
    end
    feed_data
  end

  def scraper_data_scraperwiki_style(start_date, end_date, info_logger)
    feed_data = []
    # Go through the dates in reverse chronological order
    (start_date..end_date).to_a.reverse.each do |date|
      feed_data += scraper_data(date, info_logger)
    end
    feed_data    
  end

  def scraper_data_date_range(start_date, end_date, info_logger)
    if scraperwiki?
      scraper_data_scraperwiki_style(start_date, end_date, info_logger)
    else
      scraper_data_original_style(start_date, end_date, info_logger)
    end
  end

  # Collect all the applications for this authority by scraping
  def collect_applications_date_range(start_date, end_date, info_logger = logger)
    count = 0
    scraper_data_date_range(start_date, end_date, info_logger).each do |attributes|
      # TODO Consider if it would be better to overwrite applications with new data if they already exists
      # This would allow for the possibility that the application information was incorrectly entered at source
      # and was updated. But we would have to think whether those updated applications should get mailed out, etc...
      unless applications.find_by_council_reference(attributes[:council_reference])
        count += 1
        applications.create!(attributes)
      end
    end

    if count > 0
      info_logger.info "#{count} new applications found for #{full_name_and_state}"
    end
  end

  # Returns an array of arrays [date, number_of_applications_that_date]
  def applications_per_day
    h = applications.group("CAST(date_scraped AS DATE)").count
    # For any dates not in h fill them in with zeros
    (h.keys.min..Date.today).each do |date|
      h[date] = 0 unless h.has_key?(date)
    end
    h.sort
  end

  def median_applications_per_week
    v = applications_per_week.map{|a| a[1]}.sort
    v[v.count / 2]
  end

  def applications_per_week
    # Sunday is the beginning of the week (and the date returned here)
    # Have to compensate for MySQL which treats Monday as the beginning of the week
    h = applications.group("CAST(SUBDATE(date_scraped, WEEKDAY(date_scraped) + 1) AS DATE)").count
    min = h.keys.min
    max = Date.today - Date.today.wday
    (min..max).step(7) do |date|
      h[date] = 0 unless h.has_key?(date)
    end
    h.sort
  end

  # When this authority started on PlanningAlerts. Just the date of the earliest scraped application
  def earliest_date
    # Removing default scoping by using "unscoped". Hmmm. Maybe get rid of default scoping entirely?
    earliest_application = applications.unscoped.order("date_scraped").first
    earliest_application.date_scraped if earliest_application
  end

  # Does this authority use scraperwiki to get its data?
  def scraperwiki?
    scraperwiki_name && scraperwiki_name != ""
  end

  def scraperwiki_url
    "https://scraperwiki.com/scrapers/#{scraperwiki_name}/" if scraperwiki?
  end
  
  def feed_url_for_date(date)
    feed_url.sub("{year}", date.year.to_s).sub("{month}", date.month.to_s).sub("{day}", date.day.to_s)
  end

  def scraperwiki_feed_url_for_date(date)
    query = CGI.escape("select * from swdata where `date_scraped`='#{date}'")
    "https://api.scraperwiki.com/api/1.0/datastore/sqlite?format=jsondict&name=#{scraperwiki_name}&query=#{query}"
  end

  def scraperwiki_feed_url_for_date_range(start_date, end_date)
    query = CGI.escape("select * from swdata where `date_scraped`=>'#{start_date}' and `date_scraped`<='#{end_date}'")
    "https://api.scraperwiki.com/api/1.0/datastore/sqlite?format=jsondict&name=#{scraperwiki_name}&query=#{query}"
  end
  
  # So that the encoding function can be used elsewhere
  def self.short_name_encoded(short_name)
    short_name.downcase.gsub(' ', '_').gsub(/\W/, '')
  end
  
  def short_name_encoded
    Authority.short_name_encoded(short_name)
  end
  
  def self.find_by_short_name_encoded(n)
    # TODO: Potentially not very efficient when number of authorities is high. Loads all authorities into memory
    find(:all).find{|a| a.short_name_encoded == n}
  end
  
  # Is this authority contactable through PlanningAlerts? i.e. do we have an email address on record?
  def contactable?
    email && email != ""
  end

  def latest_application
    # The applications are sorted by default by the date_scraped because of the default scope on the model
    latest = applications.find(:first)
    if latest
      latest.date_scraped
    end
  end

  # If the latest application is over two weeks old, the scraper's probably broken
  def broken?
    return false if !self.latest_application
    self.latest_application < Time.now - 14.days
  end
end
