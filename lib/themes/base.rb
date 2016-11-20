module Themes
  class Base
    def domain
      host.split(":").first
    end

    def view_path
      nil
    end

    def ssl_required?
      true
    end

    def view_path
      path = Rails.root.join('lib', 'themes', self.name, 'views')
      if File.directory? path
        path
      else
        nil
      end
    end

    def env_file
      path = Rails.root.join('lib', 'themes', self.name, '.env')
      if File.exists? path
        path
      else
        nil
      end
    end

    def country_code
      ENV['COUNTRY_CODE']
    end

    # This might have a port number included
    def host
      ENV["HOST"]
    end

    def protocol
      ssl_required? ? "https" : "http"
    end

    def delivery_options
      {}
    end

    def google_analytics_key
      ENV["GOOGLE_ANALYTICS_KEY"]
    end

    def app_name
      ENV["EMAIL_FROM_NAME"]
    end

    def email_from_address
      ENV["EMAIL_FROM_ADDRESS"]
    end

    def google_maps_client_id
      ENV["GOOGLE_MAPS_CLIENT_ID"]
    end

    def asset_paths
      Dir.glob(Rails.root.join('lib', 'themes', self.name, 'assets', '*'))
    end

    def email_from
      "#{app_name} <#{email_from_address}>"
    end

    def default_meta_description
      ENV['META_DESCRIPTION']
    end
  end
end
