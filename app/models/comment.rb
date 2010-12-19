class Comment < ActiveRecord::Base
  belongs_to :application
  validates_presence_of :email, :name, :text
  validates_email_format_of :email
end
