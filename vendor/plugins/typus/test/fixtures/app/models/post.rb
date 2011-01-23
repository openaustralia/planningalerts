class Post < ActiveRecord::Base

  validates_presence_of :title, :body
  has_and_belongs_to_many :categories
  has_many :assets, :as => :resource, :dependent => :destroy
  has_many :comments
  has_many :views
  belongs_to :favorite_comment, :class_name => 'Comment'

  STATUS = %w( pending published unpublished )

  def self.typus
    'plugin'
  end

  def asset_file_name
  end

end