module Themes
  module Default
    class Theme < Themes::Base

      def name
        "default"
      end

      def host
        ActionMailer::Base.default_url_options[:host]
      end

    end
  end
end
