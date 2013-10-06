class Comment < ActiveRecord::Base
  belongs_to :application
  has_many :reports
  validates_presence_of :name, :text, :address
  
  acts_as_email_confirmable
  scope :visible, :conditions => {:confirmed => true, :hidden => false}
  scope :in_past_week, where("created_at > ?", 7.days.ago)
  
  # Send the comment to the planning authority
  def after_confirm
    CommentNotifier.notify(self).deliver
  end
end
