# frozen_string_literal: true

module ApplicationsHelper
  def display_description_with_address(application)
    display_description =
      if application.description
        "“#{truncate(application.description, escape: false, separator: ' ')}” at"
      else
        "application for"
      end

    "#{display_description} #{application.address}"
  end

  def scraped_and_received_text(application)
    text = +"We found this application for you on the planning authority's website #{time_ago_in_words(application.date_scraped)} ago. "
    text << if application.date_received
              "It was received by them #{distance_of_time_in_words(application.date_received, application.date_scraped)} earlier."
            else
              "The date it was received by them was not recorded."
            end
    text
  end

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

  # TODO: Fix this (unused _application)
  def page_title(_application)
    # Include the scraping date in the title so that multiple applications from the same address have different titles
    "#{@application.address} | #{@application.date_scraped.to_date.to_formatted_s(:rfc822)}"
  end

  def authority_applications_json_url_for_current_user(authority)
    link_params = { format: :js, key: current_user.api_key }
    link_params[:host] = api_host if Rails.env.production?

    authority_applications_url(authority.short_name_encoded, link_params)
  end

  def google_static_map(application, options)
    google_static_map2(options.merge(lat: application.lat, lng: application.lng, label: "Map of #{application.address}"))
  end

  # Version of google_static_map above that isn't tied into the implementation of Application
  def google_static_map2(options)
    size = options[:size] || "350x200"
    label = options[:label] || "Map"
    image_tag(google_static_map_url(options), size: size, alt: label)
  end

  def google_static_map_url(options)
    zoom = options[:zoom] || 16
    lat = options[:lat]
    lng = options[:lng]
    size = options[:size] || "350x200"
    google_signed_url(
      "https://maps.googleapis.com",
      "/maps/api/staticmap",
      {
        maptype: "roadmap",
        markers: "color:red|#{lat},#{lng}",
        size: size,
        zoom: zoom
      }.to_query
    )
  end

  def google_static_streetview_url(application, options)
    size = options[:size] || "350x200"
    fov = options[:fov] || 90
    google_signed_url(
      "https://maps.googleapis.com",
      "/maps/api/streetview",
      {
        fov: fov,
        location: "#{application.lat},#{application.lng}",
        size: size
      }.to_query
    )
  end

  def google_static_streetview(application, options)
    size = options[:size] || "350x200"
    image_tag(google_static_streetview_url(application, options), size: size, alt: "Streetview of #{application.address}")
  end

  private

  def google_signed_url(domain, path, query)
    client_id = ENV["GOOGLE_MAPS_CLIENT_ID"]
    google_maps_key = ENV["GOOGLE_MAPS_API_KEY"]
    cryptographic_key = ENV["GOOGLE_MAPS_CRYPTOGRAPHIC_KEY"]
    if client_id.present?
      signed = path + "?" + query + "&client=#{client_id}"
      signature = sign_gmap_bus_api_url(signed, cryptographic_key)
      domain + signed + "&signature=#{signature}"
    elsif google_maps_key.present?
      signed = path + "?" + query + "&key=#{google_maps_key}"
      signature = sign_gmap_bus_api_url(signed, cryptographic_key)
      domain + signed + "&signature=#{signature}"
    else
      domain + path + "?" + query
    end
  end

  # This code comes from Googles Examples
  # http://gmaps-samples.googlecode.com/svn/trunk/urlsigning/urlsigner.rb
  def sign_gmap_bus_api_url(url_to_sign, google_cryptographic_key)
    # Decode the private key
    raw_key = Base64.decode64(google_cryptographic_key.tr("-_", "+/"))
    # create a signature using the private key and the URL
    raw_signature = OpenSSL::HMAC.digest("sha1", raw_key, url_to_sign)
    # encode the signature into base64 for url use form.
    Base64.encode64(raw_signature).tr("+/", "-_").delete("\n")
  end

  def api_host
    "api.planningalerts.org.au"
  end
end
