# typed: strict
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
  extend T::Sig

  sig { returns(Integer) }
  attr_reader :size

  sig { params(filename: String).void }
  def initialize(filename)
    @writer = T.let(Zlib::GzipWriter.open(filename), Zlib::GzipWriter)
    @size = T.let(0, Integer)
  end

  sig { params(text: String).void }
  def <<(text)
    @writer << text
    @size += text.size
  end

  sig { params(filename: String).returns(CountedFile) }
  def self.open(filename)
    new(filename)
  end

  sig { void }
  def close
    @writer.close
  end
end

class Sitemap
  extend T::Sig

  sig { returns(String) }
  attr_reader :root_url

  sig { returns(String) }
  attr_reader :root_path

  # These are limits that are imposed on a single sitemap file by the specification
  MAX_URLS_PER_FILE = 50000
  # This is the uncompressed size of a single sitemap file
  MAX_BYTES_PER_FILE = 10485760

  SITEMAP_XMLNS = "http://www.sitemaps.org/schemas/sitemap/0.9"

  sig { params(root_url: String, root_path: String, logger: Logger).void }
  def initialize(root_url, root_path, logger = Logger.new($stdout))
    @root_url = root_url
    @root_path = root_path
    @logger = logger

    FileUtils.mkdir_p "#{@root_path}/sitemaps"

    # Index of current sitemap file
    @index = T.let(0, Integer)
    @index_file = T.let(start_index, File)
    @sitemap_file = T.let(start_sitemap, CountedFile)
    @no_urls = T.let(0, Integer)
    @lastmod = T.let(nil, T.nilable(Time))
  end

  sig { returns(CountedFile) }
  def start_sitemap
    sitemap_path = "#{root_path}/#{sitemap_relative_path}"
    @logger.info "Writing sitemap file (#{sitemap_path})..."
    sitemap_file = CountedFile.open(sitemap_path)
    sitemap_file << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    sitemap_file << "<urlset xmlns=\"#{SITEMAP_XMLNS}\">"
    sitemap_file
  end

  sig { returns(File) }
  def start_index
    index_file = File.open("#{@root_path}/#{sitemap_index_relative_path}", "w")
    index_file << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    index_file << "<sitemapindex xmlns=\"#{SITEMAP_XMLNS}\">"
    index_file
  end

  sig { void }
  def finish_index
    @index_file << "</sitemapindex>"
    @index_file.close
  end

  sig { void }
  def finish_sitemap
    @sitemap_file << "</urlset>"
    @sitemap_file.close
    # Update the sitemap index
    @index_file << "<sitemap>"
    @index_file << "<loc>#{root_url}/#{sitemap_relative_path}</loc>"
    @index_file << "<lastmod>#{Sitemap.w3c_date(@lastmod)}</lastmod>"
    @index_file << "</sitemap>"
  end

  sig do
    params(
      loc: String,
      changefreq: T.nilable(Symbol),
      lastmod: T.nilable(Time)
    ).void
  end
  def add_url(loc, changefreq: nil, lastmod: nil)
    url = SitemapUrl.new(loc, changefreq:, lastmod:)
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
      @sitemap_file = start_sitemap
      @no_urls = 0
      @lastmod = nil
    end

    @sitemap_file << t
    @no_urls += 1
    # For the last modification time of the whole sitemap file use the most recent
    # modification time of all the urls in the file
    lastmod = url.lastmod
    @lastmod = lastmod if lastmod && (@lastmod.nil? || lastmod > @lastmod)
  end

  # Write any remaining bits of XML and close all the files
  sig { void }
  def finish
    finish_sitemap
    finish_index
  end

  sig { params(date: T.nilable(Time)).returns(T.nilable(String)) }
  def self.w3c_date(date)
    date&.utc&.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end

  # Path on the filesystem (relative to root_path) to the sitemap index file
  # This needs to be at the root of the web path to include all the urls below it
  sig { returns(String) }
  def sitemap_index_relative_path
    "sitemap.xml"
  end

  sig { returns(String) }
  def sitemap_relative_path
    "sitemaps/sitemap#{@index + 1}.xml.gz"
  end
end
