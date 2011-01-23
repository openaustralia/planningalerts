module Typus

  module Reloader

    # Reload config and roles when app is running in development.
    def reload_config_and_roles
      return if Rails.env.production?
      Typus::Configuration.roles!
      Typus::Configuration.config!
    end

  end

end