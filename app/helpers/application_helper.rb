require 'rss/1.0'
require 'rss/2.0'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def body_classes(controller_name, action_name)
    "c-#{controller_name} a-#{action_name}"
  end
  
  def meters_in_words(meters)
    if meters < 1000
      "#{significant_figure_remove_trailing_zero(meters, 2)} m"
    else
      "#{significant_figure_remove_trailing_zero(meters / 1000.0, 2)} km"
    end
  end
  
  def significant_figure_remove_trailing_zero(a, s)
    text = significant_figure(a, s).to_s
    if text [-2..-1] == ".0"
      text[0..-3]
    else
      text
    end
  end

  # Round the number a to s significant figures
  def significant_figure(a, s)
    if a > 0
      m = 10 ** (Math.log10(a).ceil - s)
      ((a.to_f / m).round * m).to_f
    elsif a < 0
      -significant_figure(-a, s)
    else
      0
    end
  end
  
  def km_in_words(km)
    meters_in_words(km * 1000)
  end
  
  def render_rss_feed
    render :partial => 'shared/rss_item', :collection => PlanningAlertsRSS.recent
  end
  
  def render_twitter_feed(username)
    render :partial => 'shared/tweet', :collection => TwitterFeed.new(username).items
  end
end
