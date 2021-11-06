# frozen_string_literal: true

require "spec_helper"

describe "GenerateSitemapService" do
  let!(:application) { create(:geocoded_application) }
  # A logger that only displays errrors
  let(:logger) do
    logger = Logger.new($stdout)
    logger.level = Logger::ERROR
    logger
  end

  before { FileUtils.rm_f("public/sitemaps/sitemap1.xml.gz") }

  after { FileUtils.rm_f("public/sitemaps/sitemap1.xml.gz") }

  it "includes the path of the application page" do
    GenerateSitemapService.call(logger: logger)

    Zlib::GzipReader.open("public/sitemaps/sitemap1.xml.gz") do |gz|
      expect(gz.read).to include "/applications/#{application.id}"
    end
  end
end
