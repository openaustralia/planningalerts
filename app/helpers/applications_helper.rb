module ApplicationsHelper
  def static_google_map_url(options = {:size => "512x512"})
    "http://maps.google.com/maps/api/staticmap?center=#{CGI.escape(options[:address])}&zoom=14&size=#{options[:size]}&maptype=roadmap&markers=color:blue|label:#{CGI.escape(options[:address])}|#{CGI.escape(options[:address])}&sensor=false"
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
  
  def on_notice_text(application)
    if application.on_notice_from && application.on_notice_from.future?
      text = "The period for officially responding to this application starts in <strong>#{distance_of_time_in_words(Time.now, application.on_notice_from)}</strong> and finishes #{distance_of_time_in_words(application.on_notice_from, application.on_notice_to)} later."
    elsif application.on_notice_to.future?
      text = "You have <strong>#{distance_of_time_in_words(Time.now, application.on_notice_to)}</strong> left to officially respond to this application."
      text << " The period for comment started #{time_ago_in_words(application.on_notice_from)} ago." if application.on_notice_from
    else
      text = "You're too late! The period for officially commenting on this application finished <strong>#{time_ago_in_words(application.on_notice_to)}</strong> ago."
      text << " It lasted for #{distance_of_time_in_words(application.on_notice_from, application.on_notice_to)}." if application.on_notice_from
    end
    text.html_safe
  end
  
  def page_title(application)
    # Include the scraping date in the title so that multiple applications from the same address have different titles
    "#{@application.address} | #{@application.date_scraped.to_date.to_formatted_s(:rfc822)}"
  end
end
