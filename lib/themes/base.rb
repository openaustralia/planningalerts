module Themes
  class Base
    def domain
      host.split(":").first
    end

    def view_path
      nil
    end

    def email_from
      "#{app_name} <#{email_from_address}>"
    end
  end
end