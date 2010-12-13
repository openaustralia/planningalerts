Given /^the following development applications:$/ do |table|
  table.hashes.each do |hash|
    authority = Authority.find_or_create_by_full_name_and_short_name(hash[:scraper], hash[:scraper])
    Application.create!(:address => hash[:address], :council_reference => hash[:council_reference], :date_scraped => Time.now, :authority => authority)
  end
end
