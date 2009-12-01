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
if lines.grep(/BASE_URL/).first =~ /'http(.+)'/
  base_url = "http" + $~[1]
else
  raise "Couldn't match structure of DB_CONNECTION_STRING line in php configuration file"
end

# This URL returns a list of scrapers
internal_scraper_url = "#{base_url}/scrapers/"

ActiveRecord::Base.establish_connection(
        :adapter  => "mysql",
        :host     => host,
        :username => username,
        :password => password,
        :database => database
)

class Authority < ActiveRecord::Base
  set_table_name "authority"
end

# Brutal: blast away all the data in the authority table!
Authority.delete_all

agent = WWW::Mechanize.new
# Quick little hack to get around the fact that the test instance is password protected
if internal_scraper_url == "http://test.planningalerts.org.au/scrapers/"
  agent.auth("test", "test")
end

page = agent.get(internal_scraper_url)
Nokogiri::XML(page.body).search('scraper').each do |scraper|
  authority = Authority.new(:full_name => scraper.at('authority_name').inner_text,
    :short_name => scraper.at('authority_short_name').inner_text,
    :feed_url => scraper.at('url').inner_text,
    # TODO Find a way of setting the planning email address or maybe it's not used at all
    :planning_email => "unknown@unknown.org",
    :external => 1,
    :disabled => 0)
  authority.save!
end

puts "All is good."

