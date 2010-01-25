class Authority < ActiveRecord::Base
  set_table_name "authority"
  set_primary_key "authority_id"
  
  named_scope :active, :conditions => 'disabled = 0 or disabled is null'
end
