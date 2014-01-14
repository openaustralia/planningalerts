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
    render :partial => 'shared/rss_item', :collection => PlanningAlertsRSS.recent, :as => :item
  end
  
  def render_twitter_feed(username)
    render :partial => 'shared/tweet', :collection => TwitterFeed.new(username).items, :as => :item
  end

  def contributors
    [
      { :name => "Roger Barnes", :email_md5 => "dd6c985d22e3bf6ea849e8d2e6750d76" },
      { :name => "Sam Cavenagh", :email_md5 => "64afebb884d0f21f860076f4b8a92f50" },
      { :name => "Henare Degan", :email_md5 => "b30d37e67e4c4584a71d977763651513" },
      { :name => "Nick Evershed", :email_md5 => "7289b45ea6e9ac313bd4c34d7f4e461b" },
      { :name => "Andrew Harvey", :email_md5 => "7284ad488e18a2b052a9c7b8fe1e3922" },
      { :name => "Mark Kinkade", :email_md5 => "1aac9f1adece54cc394b8cf6d8c84a1a" },
      { :name => "Matthew Landauer", :email_md5 => "5a600494d91ea4223e7256989155f687" },
      { :name => "Adrian Miller", :email_md5 => "fab3189512311073ccf49928112c98fa" },
      { :name => "Peter Neish", :email_md5 => "00477410c5069d49fad6eedaea32fd61" },
      { :name => "Daniel O'Connor", :email_md5 => "353d83d3677b142520987e1936fd093c" },
      { :name => "Andrew Perry", :email_md5 => "7d329af0dcfe18c8797f542938286e46" },
      { :name => "James Polley", :email_md5 => "06a0058c9d6dc0eac55c3311a99beeda" },
      { :name => "Alex (Maxious) Sadleir", :email_md5 => "5944d4aed96852cb4ce78db3d74edec" },
      { :name => "Kris Splittgerber", :email_md5 => "d330c3271cdd9aab9e9e5c360235b6dc" },
      { :name => "Adam Stiskala", :email_md5 => "f1b38bb55fedf270d3cd7c049176c09e" },
      { :name => "Katherine Szuminska", :email_md5 => "23d3fa4bbac53c44edef4ff672b9816a" },
      { :name => "Justin Wells", :email_md5 => "3c1983a3371799ba1a78606dc62655db" }
    ]
  end
end
