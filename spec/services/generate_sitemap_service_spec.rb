# frozen_string_literal: true

require "spec_helper"

describe "GenerateSitemapService" do
  let(:application) { create(:geocoded_application) }
  # A logger that only displays errrors
  let(:logger) do
    logger = Logger.new(STDOUT)
    logger.level = Logger::ERROR
    logger
  end

  before(:each) { application }
  before(:each) { FileUtils.rm_f("public/sitemaps/sitemap1.xml.gz") }
  after(:each) { FileUtils.rm_f("public/sitemaps/sitemap1.xml.gz") }

  it "should include the path of the application page" do
    GenerateSitemapService.new.generate(logger)

    Zlib::GzipReader.open("public/sitemaps/sitemap1.xml.gz") do |gz|
      expect(gz.read).to include "/applications/#{application.id}"
    end
  end
end
