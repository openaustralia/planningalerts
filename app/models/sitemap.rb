# typed: true
# frozen_string_literal: true

require "zlib"

class SitemapUrl
  extend T::Sig

  sig { returns(String) }
  attr_reader :loc

  # TODO: Make this return symbol for consistency
  sig { returns(T.nilable(String)) }
  attr_reader :changefreq

  sig { returns(T.nilable(Time)) }
  attr_reader :lastmod

  CHANGEFREQ_VALUES = T.let(%w[always hourly daily weekly monthly yearly never"].freeze, T::Array[String])

  sig { params(loc: String, changefreq: T.nilable(Symbol), lastmod: T.nilable(Time)).void }
  def initialize(loc, changefreq: nil, lastmod: nil)
    @loc = loc
    @changefreq = T.let(changefreq&.to_s, T.nilable(String))
    @lastmod = lastmod
    throw "Invalid value #{@changefreq} for changefreq" unless @changefreq.nil? || CHANGEFREQ_VALUES.include?(@changefreq)
  end
end

# Like a Zlib::GzipWriter class but also counts the number of bytes (uncompressed) written out
class CountedFile
  attr_reader :size

  def initialize(filename)
    @writer = Zlib::GzipWriter.open(filename)
    @size = 0
  end

  def <<(text)
    @writer << text
    @size += text.size
  end

  def self.open(filename)
    new(filename)
  end

  def close
    @writer.close
  end
end

class Sitemap
  attr_reader :root_url, :root_path

  # These are limits that are imposed on a single sitemap file by the specification
  MAX_URLS_PER_FILE = 50000
  # This is the uncompressed size of a single sitemap file
  MAX_BYTES_PER_FILE = 10485760

  SITEMAP_XMLNS = "http://www.sitemaps.org/schemas/sitemap/0.9"

  def initialize(root_url, root_path, logger = Logger.new(STDOUT))
    @root_url = root_url
    @root_path = root_path
    @logger = logger

    FileUtils.mkdir_p "#{@root_path}/sitemaps"

    # Index of current sitemap file
    @index = 0
    start_index
    start_sitemap
  end

  def start_sitemap
    sitemap_path = "#{root_path}/#{sitemap_relative_path}"
    @logger.info "Writing sitemap file (#{sitemap_path})..."
    @sitemap_file = CountedFile.open(sitemap_path)
    @sitemap_file << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    @sitemap_file << "<urlset xmlns=\"#{SITEMAP_XMLNS}\">"
    @no_urls = 0
    @lastmod = nil
  end

  def start_index
    @index_file = File.open("#{@root_path}/#{sitemap_index_relative_path}", "w")
    @index_file << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    @index_file << "<sitemapindex xmlns=\"#{SITEMAP_XMLNS}\">"
  end

  def finish_index
    @index_file << "</sitemapindex>"
    @index_file.close
  end

  def finish_sitemap
    @sitemap_file << "</urlset>"
    @sitemap_file.close
    # Update the sitemap index
    @index_file << "<sitemap>"
    @index_file << "<loc>#{root_url}/#{sitemap_relative_path}</loc>"
    @index_file << "<lastmod>#{Sitemap.w3c_date(@lastmod)}</lastmod>"
    @index_file << "</sitemap>"
  end

  def add_url(loc, options = {})
    url = SitemapUrl.new(loc, options)
    # Now build up the bit of XML that we're going to add (as a string)
    t = +"<url>"
    t << "<loc>#{root_url}#{url.loc}</loc>"
    t << "<changefreq>#{url.changefreq}</changefreq>" if url.changefreq
    t << "<lastmod>#{Sitemap.w3c_date(url.lastmod)}</lastmod>" if url.lastmod
    t << "</url>"

    # First check if we need to start a new sitemap file
    if (@no_urls == MAX_URLS_PER_FILE) || (@sitemap_file.size + t.size + "</urlset>".size > MAX_BYTES_PER_FILE)
      finish_sitemap
      @index += 1
      start_sitemap
    end

    @sitemap_file << t
    @no_urls += 1
    # For the last modification time of the whole sitemap file use the most recent
    # modification time of all the urls in the file
    lastmod = url.lastmod
    @lastmod = lastmod if lastmod && (@lastmod.nil? || lastmod > @lastmod)
  end

  # Write any remaining bits of XML and close all the files
  def finish
    finish_sitemap
    finish_index
  end

  def self.w3c_date(date)
    date&.utc&.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end

  # Path on the filesystem (relative to root_path) to the sitemap index file
  # This needs to be at the root of the web path to include all the urls below it
  def sitemap_index_relative_path
    "sitemap.xml"
  end

  def sitemap_relative_path
    "sitemaps/sitemap#{@index + 1}.xml.gz"
  end
end
