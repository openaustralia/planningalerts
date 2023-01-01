# typed: strict
# frozen_string_literal: true

module ApplicationsHelper
  extend T::Sig

  # For sorbet
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::AssetTagHelper
  include ApplicationHelper

  sig { params(application: Application).returns(String) }
  def display_description_with_address(application)
    "“#{truncate(application.description, escape: false, separator: ' ')}” at #{application.address}"
  end

  sig { params(date: Date).returns(String) }
  def days_ago_in_words(date)
    case date
    when Time.zone.today
      "today"
    when Time.zone.today - 1.day
      "yesterday"
    else
      "#{distance_of_time_in_words(date, Time.zone.today)} ago"
    end
  end

  sig { params(date: Date).returns(String) }
  def days_in_future_in_words(date)
    case date
    when Time.zone.today
      "today"
    when Time.zone.today + 1.day
      "tomorrow"
    else
      "in #{distance_of_time_in_words(Time.zone.today, date)}"
    end
  end

  # Useful for when you're showing a human readable relative date (e.g. "5 days ago") but
  # also want to have a machine readable exact date and an exact date that displays on hover
  # to the user
  sig { params(time: T.any(Time, Date), content: String).returns(String) }
  def time_tag_with_hover(time, content)
    content_tag(:time, content, datetime: time.iso8601, title: time.to_fs(:rfc822))
  end

  sig { params(application: Application).returns(String) }
  def on_notice_text(application)
    t = []
    if application.on_notice_from && (Time.zone.today < application.on_notice_from)
      t << "The period to have your comment officially considered by the planning authority"
      t << content_tag(:strong, "starts #{days_in_future_in_words(application.on_notice_from)}")
      t << "and finishes #{distance_of_time_in_words(application.on_notice_from, application.on_notice_to)} later."
    elsif Time.zone.today == application.on_notice_to
      t << content_tag(:strong, "Today is the last day")
      t << "to have your comment officially considered by the planning authority."
      t << "The period for comment started #{days_ago_in_words(application.on_notice_from)}." if application.on_notice_from
    elsif Time.zone.today < application.on_notice_to
      t << content_tag(:strong, "You have #{distance_of_time_in_words(Time.zone.today, application.on_notice_to)} left")
      t << "to have your comment officially considered by the planning authority."
      t << "The period for comment started #{days_ago_in_words(application.on_notice_from)}." if application.on_notice_from
    else
      t << "You're too late! The period for officially commenting on this application"
      t << safe_join([content_tag(:strong, "finished #{days_ago_in_words(application.on_notice_to)}"), "."])
      t << "It lasted for #{distance_of_time_in_words(application.on_notice_from, application.on_notice_to)}." if application.on_notice_from
      t << "If you chose to comment now, your comment will still be displayed here and be sent to the planning authority but it will"
      t << content_tag(:strong, "not be officially considered")
      t << "by the planning authority."
    end
    safe_join(t, " ")
  end

  sig { params(application: Application).returns(String) }
  def page_title(application)
    # Include the scraping date in the title so that multiple applications from the same address have different titles
    "#{application.address} | #{application.first_date_scraped.to_date.to_fs(:rfc822)}"
  end

  sig { params(application: Application, size: String, zoom: Integer, key: String).returns(String) }
  def google_static_map(application, size: "350x200", zoom: 16, key: "GOOGLE_MAPS_API_KEY")
    google_static_map_lat_lng(lat: application.lat, lng: application.lng, label: "Map of #{application.address}", size:, zoom:, key:)
  end

  # Version of google_static_map above that isn't tied into the implementation of Application
  sig { params(lat: Float, lng: Float, size: String, label: String, zoom: Integer, key: String).returns(String) }
  def google_static_map_lat_lng(lat:, lng:, size: "350x200", label: "Map", zoom: 16, key: "GOOGLE_MAPS_API_KEY")
    url = google_static_map_url(lat:, lng:, zoom:, size:, key:)
    image_tag(url, size:, alt: label)
  end

  sig { params(lat: T.nilable(Float), lng: T.nilable(Float), zoom: Integer, size: String, key: String).returns(T.nilable(String)) }
  def google_static_map_url(lat:, lng:, zoom: 16, size: "350x200", key: "GOOGLE_MAPS_API_KEY")
    return if lat.nil? || lng.nil?

    google_signed_url(
      domain: "https://maps.googleapis.com",
      path: "/maps/api/staticmap",
      query: {
        maptype: "roadmap",
        markers: "color:red|#{lat},#{lng}",
        size:,
        zoom:
      },
      key:
    )
  end

  sig { params(lat: Float, lng: Float, size: String, fov: Integer, key: String).returns(String) }
  def google_static_streetview_url(lat:, lng:, size: "350x200", fov: 90, key: "GOOGLE_MAPS_API_KEY")
    google_signed_url(
      domain: "https://maps.googleapis.com",
      path: "/maps/api/streetview",
      query: {
        fov:,
        location: "#{lat},#{lng}",
        size:
      },
      key:
    )
  end

  sig { params(application: Application, size: String, fov: Integer, key: String).returns(String) }
  def google_static_streetview(application, size: "350x200", fov: 90, key: "GOOGLE_MAPS_API_KEY")
    url = google_static_streetview_url(lat: application.lat, lng: application.lng, size:, fov:, key:)
    image_tag(url, size:, alt: "Streetview of #{application.address}")
  end

  HEADING_SECTOR_NAMES = T.let(%w[north northeast east southeast south southwest west northwest].freeze, T::Array[String])

  sig { params(degrees: Float).returns(String) }
  def heading_in_words(degrees)
    # Dividing the compass into 8 sectors that are centred on north
    sector = non_symmetric_round(degrees * 8 / 360.0).modulo(8)
    T.must(HEADING_SECTOR_NAMES[sector])
  end

  # This rounds up for both and positive and negative numbers
  # You can do this natively in ruby 2.4 or 2.5 I think but
  # we don't have they yet on PlanningAlerts
  # -1.5 => -1
  # -1.0 => -1
  # -0.5 => 0
  #  0   => 0
  #  0.5 => 1
  #  1.0 => 1
  sig { params(value: Float).returns(Integer) }
  def non_symmetric_round(value)
    (value + 0.5).floor
  end

  sig { params(from: Location, to: Location).returns(String) }
  def distance_and_heading_in_words(from, to)
    "#{meters_in_words(from.distance_to(to))} #{heading_in_words(from.heading_to(to))}"
  end

  private

  sig { params(domain: String, path: String, query: T::Hash[Symbol, T.any(String, Integer)], key: String).returns(String) }
  def google_signed_url(domain:, path:, query:, key: "GOOGLE_MAPS_API_KEY")
    google_maps_key = ENV.fetch(key, nil)
    cryptographic_key = ENV.fetch("GOOGLE_MAPS_CRYPTOGRAPHIC_KEY", nil)
    if google_maps_key.present?
      signed = "#{path}?#{query.merge(key: google_maps_key).to_query}"
      signature = sign_gmap_bus_api_url(signed, cryptographic_key)
      domain + signed + "&signature=#{signature}"
    else
      "#{domain}#{path}?#{query.to_query}"
    end
  end

  # This code comes from Googles Examples
  # http://gmaps-samples.googlecode.com/svn/trunk/urlsigning/urlsigner.rb
  sig { params(url_to_sign: T.untyped, google_cryptographic_key: T.untyped).returns(String) }
  def sign_gmap_bus_api_url(url_to_sign, google_cryptographic_key)
    # Decode the private key
    raw_key = Base64.decode64(google_cryptographic_key.tr("-_", "+/"))
    # create a signature using the private key and the URL
    raw_signature = OpenSSL::HMAC.digest("sha1", raw_key, url_to_sign)
    # encode the signature into base64 for url use form.
    Base64.encode64(raw_signature).tr("+/", "-_").delete("\n")
  end

  sig { returns(String) }
  def api_host
    Rails.env.development? ? "localhost" : "api.planningalerts.org.au"
  end
end
