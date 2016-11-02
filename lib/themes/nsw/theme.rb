module Themes
  module NSW
    class Theme < Themes::Base
      def theme
        "nsw"
      end

      def ssl_required?
        false
      end

      def delivery_options
        { user_name: cuttlefish_user_name,
          password: cuttlefish_password }
      end

      def view_path
        File.expand_path('../views', __FILE__)
      end

      def recognise?(request)
        tld = domain.split(".").count - 1
        request.domain(tld) == domain
      end

      # This might have a port number included
      def host
        ENV["THEME_NSW_HOST"]
      end

      def protocol
        "http"
      end

      def app_name
        ENV["THEME_NSW_EMAIL_FROM_NAME"]
      end

      def email_from_address
        ENV["THEME_NSW_EMAIL_FROM_ADDRESS"]
      end

      def cuttlefish_user_name
        ENV["THEME_NSW_CUTTLEFISH_USER_NAME"]
      end

      def cuttlefish_password
        ENV["THEME_NSW_CUTTLEFISH_PASSWORD"]
      end

      def google_analytics_key
        ENV["THEME_NSW_GOOGLE_ANALYTICS_KEY"]
      end

      def google_maps_client_id
        nil
      end

      # TODO Put this in the config
      def default_meta_description
        "Discover what's happening in your local area in NSW. Find out about new building work. Get alerted by email."
      end
    end
  end
end