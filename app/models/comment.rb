class Comment < ActiveRecord::Base
  belongs_to :application
  validates_presence_of :name, :text
  
  acts_as_email_confirmable
end
