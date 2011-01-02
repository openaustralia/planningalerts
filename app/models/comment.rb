class Comment < ActiveRecord::Base
  belongs_to :application
  validates_presence_of :name, :text
  
  acts_as_email_confirmable
  
  after_create :send_confirmation_email
  
  def send_confirmation_email
    CommentNotifier.deliver_confirm(self)
  end
  
  def confirm!
    self.confirmed = true
    save!
    CommentNotifier.deliver_notify(self)
  end
end
