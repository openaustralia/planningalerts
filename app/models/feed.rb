# frozen_string_literal: true

class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    Date.parse(value)
  rescue ArgumentError
    record.errors.add(attribute, "is not a correctly formatted date")
  end
end

# Only used in the ATDIS test harness. It acts as a shim between
# ActiveModel and ATDIS::Feed
# TODO: Should probably have a better name that is less generic
class Feed
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :base_url, :page, :street, :suburb, :postcode,
              :lodgement_date_start, :lodgement_date_end,
              :last_modified_date_start, :last_modified_date_end

  validates :base_url, url: true
  validates :lodgement_date_start, :lodgement_date_end,
            :last_modified_date_start, :last_modified_date_end, date: true, allow_blank: true

  def initialize(options = {})
    @base_url = options[:base_url]
    @page = options[:page] ? options[:page].to_i : 1
    @street = options[:street] if options[:street].present?
    @suburb = options[:suburb] if options[:suburb].present?
    @postcode = options[:postcode] if options[:postcode].present?
    @lodgement_date_start = options[:lodgement_date_start]
    @lodgement_date_end = options[:lodgement_date_end]
    @last_modified_date_start = options[:last_modified_date_start]
    @last_modified_date_end = options[:last_modified_date_end]
  end

  def filters_set?
    @street || @suburb || @postcode ||
      @lodgement_date_start || @lodgement_date_end ||
      @last_modified_date_start || @last_modified_date_end
  end

  def self.create_from_url(url)
    feed_options = ATDIS::Feed.options_from_url(url)
    base_url = ATDIS::Feed.base_url_from_url(url)
    Feed.new(feed_options.merge(base_url: base_url))
  end

  def url
    ATDIS::Feed.new(base_url).applications_url(feed_options)
  end

  def applications
    # In development we don't have a multithreaded web server so we have to fake the serving of the data
    # Assume if the url is local it's actually for one of the test data sets. We could be more careful but
    # there is little point.
    if Rails.env.development?
      u = URI.parse(url)
      if u.host == "localhost"
        file = Feed.example_path(Rails.application.routes.recognize_path(u.path)[:number].to_i, page)
        raise RestClient::ResourceNotFound unless File.exist?(file)

        page = ATDIS::Models::Page.read_json(File.read(file))
        page.url = url
        page
      end
    else
      ATDIS::Feed.new(base_url).applications(feed_options)
    end
  end

  def persisted?
    false
  end

  def self.example_path(number, page)
    "spec/atdis_json_examples/example#{number}_page#{page}.json"
  end

  private

  def feed_options
    options = {}
    options[:page] = page if page != 1
    options[:street] = street if street
    options[:suburb] = suburb if suburb
    options[:postcode] = postcode if postcode
    options[:lodgement_date_start] = lodgement_date_start if lodgement_date_start
    options[:lodgement_date_end] = lodgement_date_end if lodgement_date_end
    options[:last_modified_date_start] = last_modified_date_start if last_modified_date_start
    options[:last_modified_date_end] = last_modified_date_end if last_modified_date_end
    options
  end
end
