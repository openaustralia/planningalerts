class Application < ActiveRecord::Base
  set_table_name "application"
  set_primary_key "application_id"
  
  belongs_to :authority
  
  named_scope :within, lambda { |p1, p2|
    { :conditions => ['lat > ? AND lng > ? AND lat < ? AND lng < ?', p1.lat, p1.lng, p2.lat, p2.lng] }
  }
end
