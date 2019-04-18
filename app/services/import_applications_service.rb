# frozen_string_literal: true

class ImportApplicationsService < ApplicationService
  def initialize(authority:, scrape_delay:, logger:, morph_api_key:)
    @authority = authority
    @start_date = Time.zone.today - scrape_delay
    @end_date = Time.zone.today
    @logger = logger
    @morph_api_key = morph_api_key
  end

  def call
    time = Benchmark.ms { import_applications_date_range }
    logger.info "Took #{(time / 1000).to_i} s to import applications from #{authority.full_name_and_state}"
  end

  # Open a url and return it's content. If there is a problem will just return nil rather than raising an exception
  def self.open_url_safe(url, logger)
    RestClient.get(url).body
  rescue StandardError => e
    logger.error "Error #{e} while getting data from url #{url}. So, skipping"
    nil
  end

  private

  attr_reader :authority, :start_date, :end_date, :morph_api_key, :logger

  # Import all the applications for this authority from morph.io
  def import_applications_date_range
    count = 0
    error_count = 0
    import_data.each do |attributes|
      # TODO: Consider if it would be better to overwrite applications with new data if they already exists
      # This would allow for the possibility that the application information was incorrectly entered at source
      # and was updated. But we would have to think whether those updated applications should get mailed out, etc...
      next if authority.applications.find_by(council_reference: attributes[:council_reference])

      begin
        CreateOrUpdateApplicationService.call(
          authority: authority,
          council_reference: attributes[:council_reference],
          attributes: attributes.reject { |k, _v| k == :council_reference }
        )
        count += 1
      rescue StandardError => e
        error_count += 1
        logger.error "Error #{e} while trying to save application #{attributes[:council_reference]} for #{authority.full_name_and_state}. So, skipping"
      end
    end

    logger.info "#{count} new applications found for #{authority.full_name_and_state} with date from #{start_date} to #{end_date}"
    return if error_count.zero?

    logger.info "#{error_count} applications errored for #{authority.full_name_and_state} with date from #{start_date} to #{end_date}"
  end

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
      {
        council_reference: a["council_reference"],
        address: a["address"],
        description: a["description"],
        info_url: a["info_url"],
        comment_url: a["comment_url"],
        date_received: (Date.parse(a["date_received"]) if a["date_received"]),
        date_scraped: Time.zone.now,
        # on_notice_from and on_notice_to tags are optional
        on_notice_from: (Date.parse(a["on_notice_from"]) if a["on_notice_from"]),
        on_notice_to: (Date.parse(a["on_notice_to"]) if a["on_notice_to"])
      }
    end
  end

  def morph_url_for_date_range
    params = {
      query: "select * from `data` where `date_scraped` >= '#{start_date}' and `date_scraped` <= '#{end_date}'",
      key: morph_api_key
    }
    "https://api.morph.io/#{authority.morph_name}/data.json?#{params.to_query}"
  end
end
