# frozen_string_literal: true

class CollectApplicationsService
  def self.collect_applications(authority, info_logger)
    time = Benchmark.ms do
      # TODO: Extract SCRAPE_DELAY as parameter
      CollectApplicationsService.collect_applications_date_range(authority, Time.zone.today - ENV["SCRAPE_DELAY"].to_i, Time.zone.today, info_logger)
    end
    info_logger.info "Took #{(time / 1000).to_i} s to collect applications from #{authority.full_name_and_state}"
  end

  # Collect all the applications for this authority by scraping
  def self.collect_applications_date_range(authority, start_date, end_date, info_logger)
    count = 0
    error_count = 0
    CollectApplicationsService.collect_unsaved_applications_date_range(authority, start_date, end_date, info_logger).each do |application|
      # TODO: Consider if it would be better to overwrite applications with new data if they already exists
      # This would allow for the possibility that the application information was incorrectly entered at source
      # and was updated. But we would have to think whether those updated applications should get mailed out, etc...
      next if authority.applications.find_by(council_reference: application.council_reference)

      begin
        application.save!
        count += 1
      rescue StandardError => e
        error_count += 1
        info_logger.error "Error #{e} while trying to save application #{application.council_reference} for #{full_name_and_state}. So, skipping"
      end
    end

    info_logger.info "#{count} new applications found for #{authority.full_name_and_state} with date from #{start_date} to #{end_date}"
    return if error_count.zero?

    info_logger.info "#{error_count} applications errored for #{authority.full_name_and_state} with date from #{start_date} to #{end_date}"
  end

  # Same as collection_applications_data_range except the applications are returned rather than saved
  def self.collect_unsaved_applications_date_range(authority, start_date, end_date, info_logger)
    d = CollectApplicationsService.scraper_data_morph_style(authority, start_date, end_date, info_logger)
    d.map do |attributes|
      authority.applications.build(attributes)
    end
  end

  def self.scraper_data_morph_style(authority, start_date, end_date, info_logger)
    text = CollectApplicationsService.open_url_safe(CollectApplicationsService.morph_feed_url_for_date_range(authority, start_date, end_date), info_logger)
    if text
      CollectApplicationsService.translate_morph_feed_data(text, info_logger)
    else
      []
    end
  end

  def self.morph_feed_url_for_date_range(authority, start_date, end_date)
    query = CGI.escape("select * from `data` where `date_scraped` >= '#{start_date}' and `date_scraped` <= '#{end_date}'")
    # TODO: Extract API key as parameter
    "https://api.morph.io/#{authority.morph_name}/data.json?query=#{query}&key=#{ENV['MORPH_API_KEY']}"
  end

  # Open a url and return it's content. If there is a problem will just return nil rather than raising an exception
  def self.open_url_safe(url, info_logger)
    RestClient.get(url).body
  rescue StandardError => e
    info_logger.error "Error #{e} while getting data from url #{url}. So, skipping"
    nil
  end

  def self.translate_morph_feed_data(feed_data, logger)
    # Just use the same as ScraperWiki for the time being. Note that if something
    # goes wrong the error message will be wrong but let's ignore that for the time being
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
      logger.error "Unexpected result from scraperwiki API: #{feed_data}"
      []
    end
  end
end
