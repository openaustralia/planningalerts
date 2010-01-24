#!/usr/bin/env ruby
# First bash at a script for loading the list of planning authorities into the database.
# Currently only supporting internal scrapers. Will be very easy to add external ones

require 'rubygems'
require 'mechanize'
require 'active_record'

# Get the database connection information from the php configuration file
lines = []
File.open("#{File.dirname(__FILE__)}/docs/include/config.php") do |f|
  lines = f.readlines
end
if lines.grep(/DB_CONNECTION_STRING/).first =~ /'mysql:\/\/(\w+):(\w+)@(\w+)\/(\w+)'/
  username, password, host, database = $~[1..4]
else
  raise "Couldn't match structure of DB_CONNECTION_STRING line in php configuration file"
end
if lines.grep(/INTERNAL_SCRAPERS_INDEX_URL/).first =~ /'http(.+)'/
  internal_scrapers_index_url = "http" + $~[1]
else
  raise "Couldn't match structure of DB_CONNECTION_STRING line in php configuration file"
end

ActiveRecord::Base.establish_connection(
        :adapter  => "mysql",
        :host     => host,
        :username => username,
        :password => password,
        :database => database
)

class Authority < ActiveRecord::Base
  set_table_name "authority"
  set_primary_key "authority_id"
end

agent = WWW::Mechanize.new
# Quick little hack to get around the fact that the test instance is password protected
if internal_scrapers_index_url == "http://test.planningalerts.org.au/scrapers/"
  agent.auth("test", "test")
end

page = agent.get(internal_scrapers_index_url)
Nokogiri::XML(page.body).search('scraper').each do |scraper|
  short_name = scraper.at('authority_short_name').inner_text
  authority = Authority.find_by_short_name(short_name)
  if authority.nil?
    puts "New authority: #{short_name}"
    authority = Authority.new(:short_name => short_name)
  else
    puts "Updating authority: #{short_name}"
  end
  authority.full_name = scraper.at('authority_name').inner_text
  authority.feed_url = scraper.at('url').inner_text
  # TODO Find a way of setting the planning email address or maybe it's not used at all
  authority.planning_email = "unknown@unknown.org"
  authority.external = 1
  authority.disabled = 0
  
  authority.save!
end

# TODO: Check if there are any authorities in the database that are not known about here

puts "All is good."

