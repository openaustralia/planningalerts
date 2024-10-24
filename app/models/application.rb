# typed: strict
# frozen_string_literal: true

class Application < ApplicationRecord
  extend T::Sig

  # For sorbet
  extend Kaminari::ConfigurationMethods::ClassMethods

  searchkick highlight: [:description],
             index_name: "pa_applications_#{Rails.env}",
             locations: [:location],
             callbacks: :async

  belongs_to :authority, touch: true
  has_many :comments, dependent: :restrict_with_exception
  has_many :versions, -> { order(id: :desc) }, class_name: "ApplicationVersion", dependent: :destroy, inverse_of: :application
  has_one :current_version, -> { where(current: true) }, class_name: "ApplicationVersion", inverse_of: :application, dependent: :restrict_with_exception

  validates :council_reference, presence: true
  validates :council_reference, uniqueness: { scope: :authority_id, case_sensitive: false }
  validates :date_scraped, :address, :description, presence: true
  validates :info_url, url: true
  validate :date_received_can_not_be_in_the_future, :validate_on_notice_period

  scope(:in_past_week, -> { where("first_date_scraped > ?", 7.days.ago) })
  scope(:recent, -> { where(first_date_scraped: 14.days.ago..) })

  sig { returns(T.class_of(ApplicationsPolicy)) }
  def self.policy_class
    # By default it would be ApplicationPolicy but this clashes with the name of the policy base class. Ugh.
    ApplicationsPolicy
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def search_data
    # lat and lon need to be symbols (rather than strings) in search_data
    # to get valid data come through searchkick for some reason
    r = attributes.symbolize_keys.merge(location: { lat:, lon: lng })
    # lonlat is encoded geo data and elasticsearch is unhappy to index this. So skip it.
    # We're capturing the geodata anyway via the "location" key
    r.delete(:lonlat)
    r
  end

  # For the benefit of kaminari. Also sets the maximum number of
  # allowed returned applications in a single API request
  max_paginates_per 100

  # The maximum number of results that are returned in a page of
  # the bulk API all method.
  sig { returns(Integer) }
  def self.max_per_page_all_api
    1000
  end

  sig { returns(String) }
  def description
    Application.normalise_description(attributes["description"])
  end

  sig { returns(String) }
  def address
    Application.normalise_address(attributes["address"])
  end

  # TODO: factor out common location accessor between Application and Alert
  sig { returns(T.nilable(Location)) }
  def location
    Location.build(lat:, lng:)
  end

  sig { returns(T::Boolean) }
  def official_submission_period_expired?
    !on_notice_to.nil? && Time.zone.today > on_notice_to
  end

  sig { returns(T.nilable(String)) }
  def comment_email_with_fallback
    comment_email.presence || T.must(authority).email
  end

  sig { returns(String) }
  def comment_recipient_full_name
    comment_authority.presence || T.must(authority).full_name
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
      point = RGeo::Geographic.spherical_factory.point(lng, lat)
      Application.where("ST_DWithin(lonlat, ?, ?)", point.to_s, Application.nearby_and_recent_max_distance_km * 1000)
                 .where.not(id:)
                 .where("first_date_scraped > ?", Application.nearby_and_recent_max_age_months.months.ago)
    else
      Application.none
    end
  end

  sig { returns(ActiveRecord::Relation) }
  def self.trending
    where("first_date_scraped > ?", 6.months.ago).order(visible_comments_count: :desc)
  end

  sig { params(description: String).returns(String) }
  def self.normalise_description(description)
    # If whole description is in upper case switch the whole description to lower case
    description = description.downcase if description.upcase == description
    description.split(". ").map do |sentence|
      words = sentence.split
      # Capitalise the first word of the sentence if it's all lowercase
      first = words[0]
      words[0] = first.capitalize if first && first.downcase == first
      words.join(" ")
    end.join(". ")
  end

  sig { params(address: String).returns(String) }
  def self.normalise_address(address)
    exceptions = %w[QLD VIC NSW SA ACT TAS WA NT]

    address.split.map do |word|
      if word != word.upcase || exceptions.any? { |exception| word =~ /^\W*#{exception}\W*$/ } || word =~ /\d/
        word
      else
        word.capitalize
      end
    end.join(" ")
  end

  sig { params(address: String).returns(T::Hash[Symbol, T.untyped]) }
  def self.geocode_attributes(address)
    r = GeocodeService.call(
      address:,
      google_key: Rails.application.credentials.dig(:google_maps, :server_key),
      mappify_key: Rails.application.credentials[:mappify_api_key]
    )
    top = r.top
    if top
      # TODO: Can we get the factory from the database info instead?
      factory = RGeo::Geographic.spherical_factory(srid: 4326)
      {
        lat: top.lat,
        lng: top.lng,
        lonlat: factory.point(top.lng, top.lat),
        suburb: top.suburb,
        # Hack - workaround for inconsistent returned state name (as of 21 Jan 2011)
        # from Google Geocoder
        state: top.state == "New South Wales" ? "NSW" : top.state,
        postcode: top.postcode
      }
    else
      logger.error "Couldn't geocode address: #{address} (#{r.error})"
      {}
    end
  end

  private

  sig { void }
  def date_received_can_not_be_in_the_future
    d = date_received
    return unless d && d > Time.zone.today

    errors.add(:date_received, "can not be in the future")
  end

  sig { void }
  def validate_on_notice_period
    from = on_notice_from
    to = on_notice_to

    return unless from && to && from > to

    errors.add(:on_notice_to, "can not be earlier than the start of the on notice period")
  end
end
