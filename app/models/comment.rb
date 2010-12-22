class Comment < ActiveRecord::Base
  belongs_to :application
  validates_presence_of :email, :name, :text
  validates_email_format_of :email
  
  before_create :set_confirm_info
  
  private
  
  # TODO: This is currently duplicated from alert model. Should extract this!
  def set_confirm_info
    # TODO: Should check that this is unique across all alerts and if not try again
    self.confirm_id = Digest::MD5.hexdigest(rand.to_s + Time.now.to_s)[0...20]
  end
end
