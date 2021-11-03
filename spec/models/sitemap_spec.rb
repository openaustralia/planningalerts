# frozen_string_literal: true

require "spec_helper"

describe Sitemap do
  before :each do
    # Make the logging more silent during testing. Only display errors not general chit-chat.
    @logger = Logger.new($stdout)
    @logger.level = Logger::ERROR
  end

  it "should output an xml sitemap" do
    public = Rails.root.join("public").to_s

    file1 = File.new("foo", "w")
    expect(File).to receive(:open).with("#{public}/sitemap.xml", "w").and_return(file1)
    expect(file1).to receive(:<<).with("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
    expect(file1).to receive(:<<).with("<sitemapindex xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">")
    expect(file1).to receive(:<<).with("<sitemap>")
    expect(file1).to receive(:<<).with("<loc>http://domain.org/sitemaps/sitemap1.xml.gz</loc>")
    expect(file1).to receive(:<<).with("<lastmod>2010-02-01T00:00:00+00:00</lastmod>")
    expect(file1).to receive(:<<).with("</sitemap>")
    expect(file1).to receive(:<<).with("</sitemapindex>")
    expect(file1).to receive(:close).and_call_original

    file2 = Zlib::GzipWriter.new(StringIO.new)
    expect(Zlib::GzipWriter).to receive(:open).with("#{public}/sitemaps/sitemap1.xml.gz").and_return(file2)
    expect(file2).to receive(:<<).with("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
    expect(file2).to receive(:<<).with("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">")
    expect(file2).to receive(:<<).with("<url><loc>http://domain.org/</loc><changefreq>hourly</changefreq><lastmod>2010-02-01T00:00:00+00:00</lastmod></url>")
    expect(file2).to receive(:<<).with("<url><loc>http://domain.org/foo</loc><changefreq>daily</changefreq><lastmod>2010-01-01T00:00:00+00:00</lastmod></url>")
    expect(file2).to receive(:<<).with("</urlset>")
    expect(file2).to receive(:close).and_call_original

    s = Sitemap.new("http://domain.org", public, @logger)

    s.add_url "/", changefreq: :hourly, lastmod: Time.utc(2010, 2, 1)
    s.add_url "/foo", changefreq: :daily, lastmod: Time.utc(2010, 1, 1)
    s.finish
    # s.notify_search_engines
    File.delete("foo")
  end

  it "should know the web root and the file path root" do
    public = Rails.root.join("public").to_s
    s = Sitemap.new("http://domain.org", public, @logger)
    expect(s.root_url).to eq("http://domain.org")
    expect(s.root_path).to eq(public)
    s.finish
  end

  it "should have the path to one of the sitemaps" do
    public = Rails.root.join("public").to_s
    s = Sitemap.new("http://domain.org", public, @logger)
    expect(s.sitemap_relative_path).to eq("sitemaps/sitemap1.xml.gz")
    s.finish
  end

  it "should have the path to the sitemap index" do
    public = Rails.root.join("public").to_s
    s = Sitemap.new("http://domain.org", public, @logger)
    expect(s.sitemap_index_relative_path).to eq("sitemap.xml")
    s.finish
  end
end
