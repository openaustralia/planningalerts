require 'open-uri'

class Application < ActiveRecord::Base
  belongs_to :authority
  before_save :geocode
  acts_as_mappable :default_units => :kms
  
  named_scope :recent, :order => "date_scraped DESC", :limit => 100
  
  # TODO: factor out common location accessor between Application and Alert
  def location
    Location.new(lat, lng) if lat && lng
  end
  
  # Optionally pass a logger which is just used for sending informational messages to do with this long-running job to
  def self.collect_applications(info_logger = logger)
    start_date = Date.today - Configuration::SCRAPE_DELAY
    # Go through the dates in reverse chronological order
    (start_date..(Date.today)).to_a.reverse.each do |date|
      authorities = Authority.active
      info_logger.info "Scraping #{authorities.count} authorities with date #{date}"
      authorities.each do |auth|
        collect_applications_for_authority(auth, date, info_logger)
      end
    end
  end
  
  def self.collect_applications_for_authority(auth, date, info_logger = logger)
    url = auth.feed_url_for_date(date)
    begin
      feed_data = open(url).read
    rescue Exception => e
      info_logger.error "Error #{e} while getting data from url #{url}. So, skipping"
      return
    end
    feed = Nokogiri::XML(feed_data)
    applications = feed.search('application')
    
    count_new, count_old = 0, 0
    applications.each do |a|
      council_reference = a.at('council_reference').inner_text
      # TODO Consider if it would be better to overwrite applications with new data if they already exists
      # This would allow for the possibility that the application information was incorrectly entered at source
      # and was updated. But we would have to think whether those updated applications should get mailed out, etc...
      if auth.applications.find_by_council_reference(council_reference)
        count_old += 1
      else
        count_new += 1
        # on_notice_from and on_notice_to tags are optional
        on_notice_from = a.at('on_notice_from').inner_text if a.at('on_notice_from')
        on_notice_to = a.at('on_notice_to').inner_text if a.at('on_notice_to')
        auth.applications.create!(
          :council_reference => council_reference,
          :address => a.at('address').inner_text,
          :description => a.at('description').inner_text,
          :info_url => a.at('info_url').inner_text,
          :comment_url => a.at('comment_url').inner_text,
          :date_received => a.at('date_received').inner_text,
          :date_scraped => DateTime.now,
          :on_notice_from => on_notice_from,
          :on_notice_to => on_notice_to)
      end
    end
    
    if count_new > 0
      info_logger.info "#{count_new} new applications found for #{auth.full_name_and_state}"
    end
  end
  
  # TODO: This is very similar to the method in the api_howto_helper. Maybe they should be together?
  def map_url
    zoom = 15
    "http://maps.google.com/maps?q=#{CGI.escape(address)}&z=#{zoom}";
  end

  private
  
  # TODO: Optimisation is to make sure that this doesn't get called again on save when the address hasn't changed
  def geocode
    # Only geocode if location hasn't been set
    if self.lat.nil? || self.lng.nil? || self.suburb.nil? || self.state.nil? || self.postcode.nil?
      r = Location.geocode(address)
      if r.success
        self.lat = r.lat
        self.lng = r.lng
        self.suburb = r.suburb
        self.state = r.state
        self.postcode = r.postcode
      else
        logger.error "Couldn't geocode address: #{address}"
      end
    end
  end
end
