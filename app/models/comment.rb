class Comment < ActiveRecord::Base
  belongs_to :application
  validates_presence_of :name, :text
  
  acts_as_email_confirmable
  
  after_create :send_confirmation_email
  after_confirm :email_authority

  def send_confirmation_email
    CommentNotifier.deliver_confirm(self)
  end
  
  # Send the comment to the planning authority
  def email_authority
    CommentNotifier.deliver_notify(self)
  end
end
