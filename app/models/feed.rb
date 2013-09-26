# Only used in the ATDIS test harness. It acts as a shim between
# ActiveModel and ATDIS::Feed
# TODO: Should probably have a better name that is less generic
class Feed
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :base_url, :page, :postcode

  def initialize(options = {})
    @base_url = options[:base_url]
    @page = options[:page] || 1
    @postcode = options[:postcode]
  end

  def self.create_from_url(url)
    feed_options = ATDIS::Feed.options_from_url(url)
    base_url = ATDIS::Feed.base_url_from_url(url)
    Feed.new(:base_url => base_url, :page => feed_options[:page], :postcode => feed_options[:postcode])
  end

  def url
    ATDIS::Feed.new(base_url).url(feed_options)
  end

  def applications
    u = URI.parse(base_url)
    # In development we don't have a multithreaded web server so we have to fake the serving of the data
    # Assume if the url is local it's actually for one of the test data sets. We could be more careful but
    # there is little point.
    if Rails.env.development? && u.host == "localhost"
      file = example_path(Rails.application.routes.recognize_path(u.path)[:number].to_i, page)
      if File.exists?(file)
        page = ATDIS::Page.read_json(File.read(file))
        page.url = url
        page
      else
        raise RestClient::ResourceNotFound
      end
    else
      ATDIS::Feed.new(base_url).applications(feed_options)    
    end
  end

  def persisted?
    false
  end

  private

  def example_path(number, page)
    Rails.root.join("spec/atdis_json_examples/example#{number}_page#{page}.json")
  end

  def feed_options
    options = {}
    options[:page] = page if page != 1
    options[:postcode] = postcode if postcode
    options
  end
end