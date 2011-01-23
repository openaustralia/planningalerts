class Page < ActiveRecord::Base

  acts_as_tree if defined?(ActiveRecord::Acts::Tree)

end