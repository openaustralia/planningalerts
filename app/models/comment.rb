class Comment < ActiveRecord::Base
  belongs_to :application
  has_many :reports
  validates_presence_of :name, :text, :address
  
  acts_as_email_confirmable
  scope :visible, :conditions => {:confirmed => true, :hidden => false}
  
  # Send the comment to the planning authority
  def after_confirm
    CommentNotifier.notify(self).deliver
  end
end
