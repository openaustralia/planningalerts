class Application < ActiveRecord::Base
  set_table_name "application"
  set_primary_key "application_id"
  
  belongs_to :authority
  before_save :lookup_comment_tinyurl, :lookup_info_tinyurl
  
  named_scope :within, lambda { |a|
    { :conditions => ['lat > ? AND lng > ? AND lat < ? AND lng < ?', a.lower_left.lat, a.lower_left.lng, a.upper_right.lat, a.upper_right.lng] }
  }
  
  private
  
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
end
