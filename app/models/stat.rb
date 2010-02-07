class Stat < ActiveRecord::Base
  def self.applications_sent
    value_for_key "applications_sent"
  end
  
  def self.emails_sent
    value_for_key "emails_sent"
  end
  
  # Returns value for given key
  def self.value_for_key(key)
    Stat.find_or_create_by_key(:key => key, :value => 0).value
  end
end
