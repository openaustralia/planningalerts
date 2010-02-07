class Authority < ActiveRecord::Base
  set_table_name "authority"
  set_primary_key "authority_id"
  
  has_many :applications
  named_scope :active, :conditions => 'disabled = 0 or disabled is null'
  
  def self.load_from_web_service
    page = Nokogiri::XML(open(Configuration::INTERNAL_SCRAPERS_INDEX_URL).read)
    page.search('scraper').each do |scraper|
      short_name = scraper.at('authority_short_name').inner_text
      authority = Authority.find_by_short_name(short_name)
      if authority.nil?
        logger.info "New authority: #{short_name}"
        authority = Authority.new(:short_name => short_name)
      else
        logger.info "Updating authority: #{short_name}"
      end
      authority.full_name = scraper.at('authority_name').inner_text
      authority.feed_url = scraper.at('url').inner_text
      # TODO Find a way of setting the planning email address or maybe it's not used at all
      authority.planning_email = "unknown@unknown.org"
      authority.external = 1
      authority.disabled = 0

      authority.save!
    end
  end
end
