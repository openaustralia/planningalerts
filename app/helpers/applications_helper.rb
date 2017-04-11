module ApplicationsHelper
  def display_description_with_address(application)
    display_description =
      if application.description
        "“#{truncate(application.description, escape: false, separator: " ")}” at"
      else
        "application for"
      end

    "#{display_description} #{application.address}"
  end

  def static_google_map_url(options = {size: "512x512"})
    "http://maps.google.com/maps/api/staticmap?center=#{CGI.escape(options[:address])}&zoom=14&size=#{options[:size]}&maptype=roadmap&markers=color:blue|label:#{CGI.escape(options[:address])}|#{CGI.escape(options[:address])}"
  end

  def scraped_and_received_text(application)
    text = "We found this application for you on the planning authority's website #{time_ago_in_words(application.date_scraped)} ago. "
    if application.date_received
      text << "It was received by them #{distance_of_time_in_words(application.date_received, application.date_scraped)} earlier."
    else
      text << "The date it was received by them was not recorded."
    end
    text
  end

  def days_ago_in_words(date)
    case date
    when Date.today
      "today"
    when Date.today - 1.day
      "yesterday"
    else
      "#{distance_of_time_in_words(date, Date.today)} ago"
    end
  end

  def days_in_future_in_words(date)
    case date
    when Date.today
      "today"
    when Date.today + 1.day
      "tomorrow"
    else
      "in #{distance_of_time_in_words(Date.today, date)}"
    end
  end

  def on_notice_text(application)
    if application.on_notice_from && (Date.today < application.on_notice_from)
      text = "The period to have your comment officially considered by the planning authority <strong>starts #{days_in_future_in_words(application.on_notice_from)}</strong> and finishes #{distance_of_time_in_words(application.on_notice_from, application.on_notice_to)} later."
    elsif Date.today == application.on_notice_to
      text = "<strong>Today is the last day</strong> to have your comment officially considered by the planning authority."
      text << " The period for comment started #{days_ago_in_words(application.on_notice_from)}." if application.on_notice_from
    elsif Date.today < application.on_notice_to
      text = "<strong>You have #{distance_of_time_in_words(Date.today, application.on_notice_to)} left</strong> to have your comment officially considered by the planning authority."
      text << " The period for comment started #{days_ago_in_words(application.on_notice_from)}." if application.on_notice_from
    else
      text = "You're too late! The period for officially commenting on this application <strong>finished #{days_ago_in_words(application.on_notice_to)}</strong>."
      text << " It lasted for #{distance_of_time_in_words(application.on_notice_from, application.on_notice_to)}." if application.on_notice_from
      text << " If you chose to comment now, your comment will still be displayed here and be sent to the planning authority but it will <strong>not be officially considered</strong> by the planning authority."
    end
    text.html_safe
  end

  def page_title(application)
    # Include the scraping date in the title so that multiple applications from the same address have different titles
    "#{@application.address} | #{@application.date_scraped.to_date.to_formatted_s(:rfc822)}"
  end

  def authority_applications_json_path_for_current_user(authority)
    authority_applications_path(authority.short_name_encoded, format: :js, key: current_user.api_key)
  end

  def google_static_map(application, options)
    google_static_map2(options.merge(lat: application.lat, lng: application.lng, label: "Map of #{application.address}"))
  end

  # Version of google_static_map above that isn't tied into the implementation of Application
  def google_static_map2(options)
    zoom = options[:zoom] || 16
    size = options[:size] || "350x200"
    lat = options[:lat]
    lng = options[:lng]
    label = options[:label] || "Map"
    image_tag("https://maps.googleapis.com/maps/api/staticmap?zoom=#{zoom}&size=#{size}&maptype=roadmap&markers=color:red%7C#{lat},#{lng}".html_safe, size: size, alt: label)
  end

  def google_static_streetview_url(application, options)
    size = options[:size] || "350x200"
    fov = options[:fov] || 90
    "https://maps.googleapis.com/maps/api/streetview?size=#{size}&location=#{application.lat},#{application.lng}&fov=#{fov}".html_safe
  end

  def google_static_streetview(application, options)
    size = options[:size] || "350x200"
    image_tag(google_static_streetview_url(application, options), size: size, alt: "Streetview of #{application.address}")
  end

end
