class <%= options[:user_class_name] %> < ActiveRecord::Base

  ROLE = Typus::Configuration.roles.keys.sort
  LANGUAGE = Typus.locales

  enable_as_typus_user

end
