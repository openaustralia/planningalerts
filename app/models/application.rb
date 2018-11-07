require "open-uri"

class Application < ActiveRecord::Base
  belongs_to :authority
  has_many :comments
  has_many :replies, through: :comments
  before_save :geocode
  geocoded_by :address, latitude: :lat, longitude: :lng

  validates :date_scraped, :council_reference, :address, :description, presence: true
  validates :info_url, url: true
  validates :comment_url, url: { allow_blank: true, schemes: %w[http https mailto] }
  validate :date_received_can_not_be_in_the_future, :validate_on_notice_period
  validates :council_reference, uniqueness: { scope: :authority_id }

  default_scope { order "date_scraped DESC" }

  scope :in_past_week, -> { where("date_scraped > ?", 7.days.ago) }
  scope :recent, -> { where("date_scraped >= ?", 14.days.ago) }

  def date_received_can_not_be_in_the_future
    return unless date_received && date_received > Date.today

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

  def self.public_attribute_names
    %w[council_reference address description info_url comment_url
       date_scraped date_received on_notice_from on_notice_to]
  end

  # For the benefit of will_paginate
  cattr_reader :per_page
  # rubocop:disable Style/ClassVars
  @@per_page = 100
  # rubocop:enable Style/ClassVars

  # TODO: factor out common location accessor between Application and Alert
  def location
    Location.new(lat, lng) if lat && lng
  end

  # Optionally pass a logger which is just used for sending informational messages to do with this long-running job to
  def self.collect_applications(authorities, info_logger = logger)
    info_logger.info "Scraping #{authorities.count} authorities"
    authorities.each { |auth| auth.collect_applications(info_logger) }
  end

  # Translate xml data (as a string) into an array of attribute hashes that can used to create applications
  def self.translate_feed_data(feed_data)
    Nokogiri::XML(feed_data).search("application").map do |a|
      {
        council_reference: a.at("council_reference").inner_text,
        address: a.at("address").inner_text,
        description: a.at("description").inner_text,
        info_url: a.at("info_url").inner_text,
        comment_url: a.at("comment_url").inner_text,
        date_received: a.at("date_received").inner_text,
        date_scraped: Time.now,
        # on_notice_from and on_notice_to tags are optional
        on_notice_from: (a.at("on_notice_from")&.inner_text),
        on_notice_to: (a.at("on_notice_to")&.inner_text)
      }
    end
  end

  def self.translate_morph_feed_data(feed_data)
    # Just use the same as ScraperWiki for the time being. Note that if something
    # goes wrong the error message will be wrong but let's ignore that for the time being
    j = JSON.parse(feed_data)
    # Do a sanity check on the structure of the feed data
    if j.is_a?(Array) && j.all? { |a| a.is_a?(Hash) }
      j.map do |a|
        {
          council_reference: a["council_reference"],
          address: a["address"],
          description: a["description"],
          info_url: a["info_url"],
          comment_url: a["comment_url"],
          date_received: a["date_received"],
          date_scraped: Time.now,
          # on_notice_from and on_notice_to tags are optional
          on_notice_from: a["on_notice_from"],
          on_notice_to: a["on_notice_to"]
        }
      end
    else
      logger.error "Unexpected result from scraperwiki API: #{feed_data}"
      []
    end
  end

  def description
    description = read_attribute(:description)
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
    address = read_attribute(:address)
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
      nearbys(nearby_and_recent_max_distance_km, units: :km).where("date_scraped > ?", nearby_and_recent_max_age_months.months.ago)
    else
      []
    end
  end

  def official_submission_period_expired?
    on_notice_to && Date.today > on_notice_to
  end

  def current_councillors_for_authority
    authority.councillors.where(current: true).shuffle if authority.councillors.any?
  end

  def councillors_available_for_contact
    current_councillors_for_authority if authority.write_to_councillors_enabled?
  end

  private

  # TODO: Optimisation is to make sure that this doesn't get called again on save when the address hasn't changed
  def geocode
    # Only geocode if location hasn't been set
    return if lat && lng && suburb && state && postcode

    r = Location.geocode(address)
    if r.success
      self.lat = r.lat
      self.lng = r.lng
      self.suburb = r.suburb
      self.state = r.state
      # Hack - workaround for inconsistent returned state name (as of 21 Jan 2011)
      # from Google Geocoder
      self.state = "NSW" if state == "New South Wales"
      self.postcode = r.postcode
    else
      logger.error "Couldn't geocode address: #{address}"
    end
  end
end
