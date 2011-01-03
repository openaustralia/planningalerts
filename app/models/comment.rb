class Comment < ActiveRecord::Base
  belongs_to :application
  validates_presence_of :name, :text
  
  acts_as_email_confirmable
  
  after_confirm :email_authority

  # Send the comment to the planning authority
  def email_authority
    CommentNotifier.deliver_notify(self)
  end
end
