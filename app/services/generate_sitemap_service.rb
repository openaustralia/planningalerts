# typed: strict
# frozen_string_literal: true

class GenerateSitemapService
  extend T::Sig

  sig { returns(Logger) }
  attr_reader :logger

  # include GeneratedUrlHelpers
  # See https://sorbet.org/docs/error-reference#4002
  T.unsafe(self).include Rails.application.routes.url_helpers

  sig { params(logger: Logger).void }
  def self.call(logger: Logger.new($stdout))
    new(logger:).call
  end

  sig { params(logger: Logger).void }
  def initialize(logger:)
    @logger = logger
  end

  sig { void }
  def call
    s = Sitemap.new(T.must(root_url(host: ENV.fetch("HOST", nil), protocol: "https")[0..-2]), Rails.public_path.to_s, logger)

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
    Application.order("date_scraped DESC").all.find_each do |application|
      s.add_url application_path(application), changefreq: :monthly, lastmod: application.date_scraped
    end

    s.finish
  end
end
