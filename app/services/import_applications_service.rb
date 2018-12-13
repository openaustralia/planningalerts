# frozen_string_literal: true

class ImportApplicationsService
  def initialize(authority:, scrape_delay:, logger:)
    @authority = authority
    @start_date = Time.zone.today - scrape_delay
    @end_date = Time.zone.today
    @logger = logger
    @morph_api_key = ENV["MORPH_API_KEY"]
  end

  def call
    time = Benchmark.ms { collect_applications_date_range }
    logger.info "Took #{(time / 1000).to_i} s to import applications from #{authority.full_name_and_state}"
  end

  private

  attr_reader :authority, :start_date, :end_date, :morph_api_key, :logger

  # Collect all the applications for this authority by scraping
  def collect_applications_date_range
    count = 0
    error_count = 0
    collect_unsaved_applications_date_range.each do |application|
      # TODO: Consider if it would be better to overwrite applications with new data if they already exists
      # This would allow for the possibility that the application information was incorrectly entered at source
      # and was updated. But we would have to think whether those updated applications should get mailed out, etc...
      next if authority.applications.find_by(council_reference: application.council_reference)

      begin
        application.save!
        count += 1
      rescue StandardError => e
        error_count += 1
        logger.error "Error #{e} while trying to save application #{application.council_reference} for #{full_name_and_state}. So, skipping"
      end
    end

    logger.info "#{count} new applications found for #{authority.full_name_and_state} with date from #{start_date} to #{end_date}"
    return if error_count.zero?

    logger.info "#{error_count} applications errored for #{authority.full_name_and_state} with date from #{start_date} to #{end_date}"
  end

  # Same as collection_applications_data_range except the applications are returned rather than saved
  def collect_unsaved_applications_date_range
    scraper_data_morph_style.map do |attributes|
      authority.applications.build(attributes)
    end
  end

  def scraper_data_morph_style
    text = ImportApplicationsService.open_url_safe(morph_feed_url_for_date_range)
    if text
      translate_morph_feed_data(text)
    else
      []
    end
  end

  def morph_feed_url_for_date_range
    query = CGI.escape("select * from `data` where `date_scraped` >= '#{start_date}' and `date_scraped` <= '#{end_date}'")
    "https://api.morph.io/#{authority.morph_name}/data.json?query=#{query}&key=#{morph_api_key}"
  end

  # Open a url and return it's content. If there is a problem will just return nil rather than raising an exception
  def open_url_safe(url)
    RestClient.get(url).body
  rescue StandardError => e
    logger.error "Error #{e} while getting data from url #{url}. So, skipping"
    nil
  end

  def translate_morph_feed_data(feed_data)
    j = JSON.parse(feed_data)
    # Do a sanity check on the structure of the feed data
    if j.is_a?(Array) && j.all? { |a| a.is_a?(Hash) }
      j.map do |a|
        {
          council_reference: a["council_reference"],
          address: a["address"],
          description: a["description"],
          info_url: a["info_url"],
          comment_url: a["comment_url"],
          date_received: a["date_received"],
          date_scraped: Time.zone.now,
          # on_notice_from and on_notice_to tags are optional
          on_notice_from: a["on_notice_from"],
          on_notice_to: a["on_notice_to"]
        }
      end
    else
      logger.error "Unexpected result from morph API: #{feed_data}"
      []
    end
  end
end
