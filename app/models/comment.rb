class Comment < ActiveRecord::Base
  belongs_to :application
  validates_presence_of :name, :text
  
  acts_as_email_confirmable
  
  # Send the comment to the planning authority
  def after_confirm
    CommentNotifier.deliver_notify(self)
  end
end
