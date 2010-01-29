class Stat < ActiveRecord::Base
  set_primary_key "key"
  
  def self.applications_sent
    value_for_key "applications_sent"
  end
  
  def self.emails_sent
    value_for_key "emails_sent"
  end
  
  # Returns value for given key
  def self.value_for_key(key)
    stat = Stat.find(:first, :conditions => {:key => key})
    if stat
      stat.value
    else
      logger.error("Could not find key #{key} for Stat lookup")
      0
    end
  end
end
