class PlanningAlertsSitemap
  include ActionController::UrlWriter
  
  def generate_and_notify
    s = Sitemap.new(root_url(:host => Configuration::HOST)[0..-2], Rails.root.join('public'))

    # We're going to say the home page changes daily because we will probably add news on to it
    s.add_url root_path, :changefreq => :weekly, :lastmod => Time.now
    # All the applications pages
    Application.find(:all).each do |application|
      s.add_url application_path(application), :changefreq => :monthly, :lastmod => application.date_scraped
    end
    s.finish
    s.notify_search_engines(Configuration::PINGMYMAP_API_KEY)
  end
end
