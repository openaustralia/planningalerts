SitemapGenerator::Sitemap.default_host = root_url(host: ENV.fetch("HOST", nil), protocol: "https")

SitemapGenerator::Sitemap.create do
  add api_howto_path, changefreq: "monthly"
  add about_path, changefreq: "monthly"
  add faq_path, changefreq: "monthly"
  add get_involved_path, changefreq: "monthly"

  ::Application.select(:id, :date_scraped).find_each do |application|
    add application_path(application), changefreq: "monthly", lastmod: application.date_scraped
  end
end
