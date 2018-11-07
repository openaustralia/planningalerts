# frozen_string_literal: true

class PlanningAlertsSitemap
  include Rails.application.routes.url_helpers

  def generate
    s = Sitemap.new(root_url(host: ENV["HOST"])[0..-2], Rails.root.join("public"))

    # TODO: There is some redundancy between what is going on here and what is listed in the routes.rb
    # Figure out if there is a way to combine the configuration information entirely in the routing.
    # Probably only worth doing when Rails 3 comes out as the routing has completely changed and is
    # apparently much more powerful

    s.add_url root_path, changefreq: :monthly
    s.add_url api_howto_path, changefreq: :monthly
    s.add_url about_path, changefreq: :monthly
    s.add_url faq_path, changefreq: :monthly
    s.add_url get_involved_path, changefreq: :monthly

    # All the applications pages
    Application.all.each do |application|
      s.add_url application_path(application), changefreq: :monthly, lastmod: application.date_scraped
    end

    s.finish
  end
end
