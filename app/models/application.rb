class Application < ActiveRecord::Base
  set_table_name "application"
  set_primary_key "application_id"
  
  belongs_to :authority
  before_save :lookup_comment_tinyurl, :lookup_info_tinyurl, :set_date_scraped, :geocode
  
  named_scope :within, lambda { |a|
    { :conditions => ['lat > ? AND lng > ? AND lat < ? AND lng < ?', a.lower_left.lat, a.lower_left.lng, a.upper_right.lat, a.upper_right.lng] }
  }
  
  private
  
  # TODO: rename date_scraped column to updated_at so that we can use rails "magic fields"
  def set_date_scraped
    self.date_scraped = DateTime.now
  end
  
  def shorten_url(url)
    if url
      ShortURL.shorten(url, :tinyurl)
    else
      logger.warn "shortening of url was skipped for application number: #{id} because url is empty"
      nil
    end
  end
  
  def lookup_comment_tinyurl
    self.comment_tinyurl = shorten_url(comment_url)
  end
  
  def lookup_info_tinyurl
    self.info_tinyurl = shorten_url(info_url)
  end
  
  def geocode
    # Only geocode if location hasn't been set
    if self.lat.nil? && self.lng.nil?
      r = Location.geocode(address)
      self.lat = r.lat
      self.lng = r.lng
    end
  end
end
