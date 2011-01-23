class Category < ActiveRecord::Base

  acts_as_list if defined?(ActiveRecord::Acts::List)

  validates_presence_of :name
  has_and_belongs_to_many :posts

  def self.typus
  end

end