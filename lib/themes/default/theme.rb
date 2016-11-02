module Themes
  module Default
    class Theme < Themes::Base
      def theme
        "default"
      end

      def recognise?(request)
        true
      end

      def host
        ActionMailer::Base.default_url_options[:host]
      end

      def protocol
        "https"
      end

      def app_name
        ENV["EMAIL_FROM_NAME"]
      end

      def email_from_address
        ENV["EMAIL_FROM_ADDRESS"]
      end

      def google_analytics_key
        ENV["GOOGLE_ANALYTICS_KEY"]
      end

      def google_maps_client_id
        ENV["GOOGLE_MAPS_CLIENT_ID"]
      end

    # TODO Put this in the config
      def default_meta_description
        "A free service which searches Australian planning authority websites and emails you details of applications near you"
      end
    end
  end
end
