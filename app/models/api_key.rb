class ApiKey < ActiveRecord::Base
  attr_accessible :contact_email, :contact_name, :key, :organisation
end
