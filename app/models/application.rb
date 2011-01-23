require 'open-uri'

class Application < ActiveRecord::Base
  belongs_to :authority
  has_many :comments
  before_save :geocode
  acts_as_mappable :default_units => :kms
  
  default_scope :order => "date_scraped DESC"
  
  # For the benefit of will_paginate
  cattr_reader :per_page
  @@per_page = 100
  
  define_index do
    indexes description
    has date_scraped
  end
    
  # TODO: factor out common location accessor between Application and Alert
  def location
    Location.new(lat, lng) if lat && lng
  end
  
  # Optionally pass a logger which is just used for sending informational messages to do with this long-running job to
  def self.collect_applications(authorities, info_logger = logger)
    start_date = Date.today - ::Configuration::SCRAPE_DELAY
    # Go through the dates in reverse chronological order
    (start_date..(Date.today)).to_a.reverse.each do |date|
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
          :date_scraped => Time.now,
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
  
  def description
    description = read_attribute(:description)
    if description
      # If whole description is in upper case switch the whole description to lower case
      description = description.downcase if description.upcase == description  
      description.split('. ').map do |sentence|
        words = sentence.split(' ')
        # Capitalise the first word of the sentence if it's all lowercase
        words[0] = words[0].capitalize if words[0].downcase == words[0]
        words.join(' ')
      end.join('. ')
    end
  end
  
  def address
    address = read_attribute(:address)
    exceptions = %w{QLD VIC NSW SA ACT TAS WA NT}

    address.split(' ').map do |word|
      if word != word.upcase || exceptions.include?(word) || word =~ /\d/
        word
      else
        word.capitalize
      end
    end.join(' ')
  end
  
  # The value (the "fourth" dimension) needs to be scaled to the same units as the distance (km) for
  # this to be meaningful
  def fourd_distance_squared(scaled_value)
    (distance.to_f ** 2 + scaled_value ** 2)
  end
  
  # Find applications that are near the current application location and/or recently scraped. We use
  # a 4d distance metric to sort the applications. The weighting of spatial distance and time is done
  # with the "max_distance" (in kilometres) and the "max_age" (in seconds) parameters.
  # "max_distance" and "max_age" also specify an upper bound on the values that are returned.
  # For instance we might consider an application that just now been lodged that's 2 km away to be
  # just as important as an application that was lodged next door 2 months ago. In this case,
  # suitable values for "max_distance" would be 2 and "max_age" would be 2 * 4 * 7 * 24 * 60 * 60.
  # "limit" is the maximum number of applications to return
  def find_all_nearest_or_recent(max_distance = 2, max_age = 2 * 4 * 7 * 24 * 60 * 60)
    if location
      # TODO: Do the sort with SQL so that we can limit the data transferred
      apps = Application.find(:all, :origin => [location.lat, location.lng], :within => max_distance, :conditions => ['date_scraped > ?', max_age.seconds.ago])

      now = Time.now
      ratio = max_distance / max_age
      apps = apps.sort do |a,b|
        a.fourd_distance_squared((now - a.date_scraped) * ratio) <=> b.fourd_distance_squared((now - b.date_scraped) * ratio)
      end
      # Don't include the current application
      apps.delete(self)
      apps
    else
      []
    end
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
        # Hack - workaround for inconsistent returned state name (as of 21 Jan 2011)
        # from Google Geocoder
        self.state = "NSW" if self.state == "New South Wales"
        self.postcode = r.postcode
      else
        logger.error "Couldn't geocode address: #{address}"
      end
    end
  end
end
