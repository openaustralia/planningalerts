class Stat < ActiveRecord::Base
  set_primary_key "key"
  
  def self.applications_sent
    stat = Stat.find(:first, :conditions => {:key => "applications_sent"})
    raise "Could not find key: applications_sent" unless stat
    stat.value
  end
end
