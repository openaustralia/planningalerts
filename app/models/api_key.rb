class ApiKey < ActiveRecord::Base
  attr_accessible :contact_email, :contact_name, :key, :organisation
  before_create :set_key

  def set_key
    self.key = Digest::MD5.base64digest(id.to_s + rand.to_s + Time.now.to_s)[0...20]
  end
end
