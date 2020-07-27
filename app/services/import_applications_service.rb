# typed: strict
# frozen_string_literal: true

class ImportApplicationsService < ApplicationService
  extend T::Sig

  sig { params(authority: Authority, scrape_delay: Integer, logger: Logger, morph_api_key: String).void }
  def self.call(authority:, scrape_delay:, logger:, morph_api_key:)
    new(
      authority: authority,
      scrape_delay: scrape_delay,
      logger: logger,
      morph_api_key: morph_api_key
    ).call
  end

  sig { params(authority: Authority, scrape_delay: Integer, logger: Logger, morph_api_key: String).void }
  def initialize(authority:, scrape_delay:, logger:, morph_api_key:)
    @authority = authority
    @start_date = T.let(Time.zone.today - scrape_delay, Date)
    @logger = logger
    @morph_api_key = morph_api_key
  end

  sig { void }
  def call
    time = Benchmark.ms { import_applications_date_range }
    logger.info "Took #{(time / 1000).to_i} s to import applications from #{authority.full_name_and_state}"
  end

  # Open a url and return it's content. If there is a problem will just return nil rather than raising an exception
  sig { params(url: String, logger: Logger).returns(T.nilable(String)) }
  def self.open_url_safe(url, logger)
    RestClient.get(url).body
  rescue StandardError => e
    logger.error "Error #{e} while getting data from url #{url}. So, skipping"
    nil
  end

  sig { returns(String) }
  def morph_query
    filters = []
    filters << "`authority_label` = '#{authority.scraper_authority_label}'" if authority.scraper_authority_label.present?
    filters << "`date_scraped` >= '#{start_date}'"
    "select * from `data` where " + filters.join(" and ")
  end

  private

  sig { returns(Authority) }
  attr_reader :authority

  sig { returns(Date) }
  attr_reader :start_date

  sig { returns(String) }
  attr_reader :morph_api_key

  sig { returns(Logger) }
  attr_reader :logger

  # Import all the applications for this authority from morph.io
  sig { void }
  def import_applications_date_range
    count = 0
    error_count = 0
    import_data.each do |r|
      CreateOrUpdateApplicationService.call(
        authority: authority,
        council_reference: r.council_reference,
        attributes: {
          address: r.address,
          description: r.description,
          info_url: r.info_url,
          date_received: r.date_received,
          date_scraped: r.date_scraped,
          on_notice_from: r.on_notice_from,
          on_notice_to: r.on_notice_to
        }
      )
      count += 1
    rescue StandardError => e
      error_count += 1
      logger.error "Error #{e} while trying to save application #{r.council_reference} for #{authority.full_name_and_state}. So, skipping"
    end

    logger.info "#{count} #{'application'.pluralize(count)} found for #{authority.full_name_and_state} with date from #{start_date}"
    return if error_count.zero?

    logger.info "#{error_count} #{'application'.pluralize(error_count)} errored for #{authority.full_name_and_state} with date from #{start_date}"
  end

  class ImportRecord < T::Struct
    const :council_reference, String
    const :address, String
    const :description, T.nilable(String)
    const :info_url, String
    const :date_received, T.nilable(String)
    const :date_scraped, ActiveSupport::TimeWithZone
    # on_notice_from and on_notice_to are optional
    const :on_notice_from, T.nilable(String)
    const :on_notice_to, T.nilable(String)
  end

  sig { returns(T::Array[ImportRecord]) }
  def import_data
    text = ImportApplicationsService.open_url_safe(morph_url_for_date_range, logger)
    return [] if text.nil?

    j = JSON.parse(text)
    # Do a sanity check on the structure of the feed data
    unless j.is_a?(Array) && j.all? { |a| a.is_a?(Hash) }
      logger.error "Unexpected result from morph API: #{text}"
      return []
    end

    j.map do |a|
      ImportRecord.new(
        council_reference: a["council_reference"],
        address: a["address"],
        description: a["description"],
        info_url: a["info_url"],
        date_received: a["date_received"],
        date_scraped: Time.zone.now,
        # on_notice_from and on_notice_to tags are optional
        on_notice_from: a["on_notice_from"],
        on_notice_to: a["on_notice_to"]
      )
    end
  end

  sig { returns(String) }
  def morph_url_for_date_range
    params = { query: morph_query, key: morph_api_key }
    "https://api.morph.io/#{authority.morph_name}/data.json?#{params.to_query}"
  end
end
