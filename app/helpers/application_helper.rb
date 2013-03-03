require 'rss/1.0'
require 'rss/2.0'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def page_matches?(options)
    if options[:action].is_a?(Array)
      options[:action].any?{|a| current_page?(:controller => options[:controller], :action => a) }
    else
      current_page?(:controller => options[:controller], :action => options[:action])
    end
  end
  
  def li_selected(m, &block)
    content_tag(:li, capture(&block), :class => ("selected" if page_matches?(m)))
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
  
  def rss_feed_items(url)
    content = ""
    begin
      open(url, 0) do |s| content = s.read end
      feed = RSS::Parser.parse(content, false)
      return feed.channel.items[0..4] # just use the first five items
    rescue
      # This happens when the DB is empty
      return []
    end
  end
  
  def render_rss_feed(url)
    @items = rss_feed_items(url)
    render :partial => 'applications/rss'
  end
  
  def render_twitter_feed(screen_name)
    Twitter.configure do |config|
      config.consumer_key = Configuration::TWITTER_CONSUMER_KEY
      config.consumer_secret = Configuration::TWITTER_CONSUMER_SECRET
      config.oauth_token = Configuration::TWITTER_OAUTH_TOKEN
      config.oauth_token_secret = Configuration::TWITTER_OAUTH_TOKEN_SECRET
    end
    begin
      @items = Twitter.user_timeline(screen_name)[0..4]
    rescue
      @items = []
    end
    @items = @items.map do |tweet|
      item = OpenStruct.new
      item.title = tweet.text.html_safe
      item.date = tweet.created_at
      item.link = "https://twitter.com/#{screen_name}/status/#{tweet.id}"
      item
    end
    render :partial => 'applications/rss'
  end
end
