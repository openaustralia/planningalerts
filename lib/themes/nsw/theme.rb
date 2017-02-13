module Themes
  module NSW
    class Theme < Themes::Base

      def name
        "nsw"
      end

      def ssl_required?
        false
      end

      def delivery_options
        { user_name: cuttlefish_user_name,
          password: cuttlefish_password }
      end

      def total_population_covered_by_all_active_authorities
        sum = 0
        Authority.where(state: "NSW").active.each do |a|
          sum += a.population_2011 if a.population_2011
        end
        sum
      end

      def total_population_2011
        7211468
      end

      def cuttlefish_user_name
        ENV["THEME_NSW_CUTTLEFISH_USER_NAME"]
      end

      def cuttlefish_password
        ENV["THEME_NSW_CUTTLEFISH_PASSWORD"]
      end

      def google_maps_client_id
        nil
      end

    end
  end
end