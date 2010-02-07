class Application < ActiveRecord::Base
  set_table_name "application"
  set_primary_key "application_id"
  
  belongs_to :authority
  before_save :make_tinyurls
  
  named_scope :within, lambda { |a|
    { :conditions => ['lat > ? AND lng > ? AND lat < ? AND lng < ?', a.lower_left.lat, a.lower_left.lng, a.upper_right.lat, a.upper_right.lng] }
  }
  
  private
  
  def make_tinyurls
    if comment_url
      self.comment_tinyurl = ShortURL.shorten(comment_url, :tinyurl)
    else
      logger.warn "comment_url for application number: #{id} is empty"
    end
    if info_url
      self.info_tinyurl = ShortURL.shorten(info_url, :tinyurl)
    else
      logger.warn "info_url for application number: #{id} is empty"
    end
  end
end
