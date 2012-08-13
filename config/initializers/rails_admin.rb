#RailsAdmin.config do |config|
  # Remove the email alerts completely from the admin view
  # as this contains private information.
  #config.excluded_models << Alert
  # Exclude these because they are entirely automatically generated
  #config.excluded_models += [Stat, Application]
  
  #config.model Comment do
  #  list do
  #    field :text
  #  end
  #end
  
  #config.model Authority do
  #  list do    
  #    field :full_name
  #    field :state
  #    field :email
  #    field :disabled
  #  end
    
  #  edit do
  #    field :full_name
  #    field :state
  #    field :short_name
  #    field :feed_url
  #    field :disabled
  #    field :email
  #    # TODO: Temporarily comment out association as it causes a
  #    # 'stack level too deep' error
  #    #field :applications
  #  end
  #end
#end