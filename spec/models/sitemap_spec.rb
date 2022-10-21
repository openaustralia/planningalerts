# frozen_string_literal: true

require "spec_helper"

describe Sitemap do
  let(:logger) do
    # Make the logging more silent during testing. Only display errors not general chit-chat.
    logger = Logger.new($stdout)
    logger.level = Logger::ERROR
    logger
  end

  it "outputs an xml sitemap" do
    public = Rails.public_path.to_s

    file1 = File.new("foo", "w")
    allow(File).to receive(:open).with("#{public}/sitemap.xml", "w").and_return(file1)
    allow(file1).to receive(:<<)
    allow(file1).to receive(:close).and_call_original

    file2 = Zlib::GzipWriter.new(StringIO.new)
    allow(Zlib::GzipWriter).to receive(:open).with("#{public}/sitemaps/sitemap1.xml.gz").and_return(file2)
    allow(file2).to receive(:<<)
    allow(file2).to receive(:close).and_call_original

    s = described_class.new("http://domain.org", public, logger)

    s.add_url "/", changefreq: :hourly, lastmod: Time.utc(2010, 2, 1)
    s.add_url "/foo", changefreq: :daily, lastmod: Time.utc(2010, 1, 1)
    s.finish
    # s.notify_search_engines
    File.delete("foo")

    expect(file1).to have_received(:<<).with("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
    expect(file1).to have_received(:<<).with("<sitemapindex xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">")
    expect(file1).to have_received(:<<).with("<sitemap>")
    expect(file1).to have_received(:<<).with("<loc>http://domain.org/sitemaps/sitemap1.xml.gz</loc>")
    expect(file1).to have_received(:<<).with("<lastmod>2010-02-01T00:00:00+00:00</lastmod>")
    expect(file1).to have_received(:<<).with("</sitemap>")
    expect(file1).to have_received(:<<).with("</sitemapindex>")
    expect(file1).to have_received(:close)

    expect(file2).to have_received(:<<).with("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
    expect(file2).to have_received(:<<).with("<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">")
    expect(file2).to have_received(:<<).with("<url><loc>http://domain.org/</loc><changefreq>hourly</changefreq><lastmod>2010-02-01T00:00:00+00:00</lastmod></url>")
    expect(file2).to have_received(:<<).with("<url><loc>http://domain.org/foo</loc><changefreq>daily</changefreq><lastmod>2010-01-01T00:00:00+00:00</lastmod></url>")
    expect(file2).to have_received(:<<).with("</urlset>")
    expect(file2).to have_received(:close)
  end

  it "knows the web root and the file path root" do
    public = Rails.public_path.to_s
    s = described_class.new("http://domain.org", public, logger)
    expect(s.root_url).to eq("http://domain.org")
    expect(s.root_path).to eq(public)
    s.finish
  end

  it "has the path to one of the sitemaps" do
    public = Rails.public_path.to_s
    s = described_class.new("http://domain.org", public, logger)
    expect(s.sitemap_relative_path).to eq("sitemaps/sitemap1.xml.gz")
    s.finish
  end

  it "has the path to the sitemap index" do
    public = Rails.public_path.to_s
    s = described_class.new("http://domain.org", public, logger)
    expect(s.sitemap_index_relative_path).to eq("sitemap.xml")
    s.finish
  end
end
