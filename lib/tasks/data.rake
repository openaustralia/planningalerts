require 'open-uri'
require 'json'

namespace :data do

  def generate_shortname(name)
    known_exceptions = {
      "Wellington (A)" => "wellington_nsw",
      "Kingston (DC)" => "kingston_sa",
      "Latrobe (M)" => "latrobe_tas",
      "Murray (A)" => "murray_nsw",
      "Flinders (S)" => "flinders_qld",
      "Central Highlands (M)" => "central_highlands_tas"
    }

    known_exceptions[name] || name.split(" (").first.downcase.gsub(" ", "_")
  end

  path = Rails.root.join("tmp/lga_2015_aust.geojson")

  desc "Fetch ABS LGA data"
  task :fetch_lgas do
    # If we want to load in geometry: the_geom or the_geom_webmercator
    query = "select cartodb_id, lga_name15, ste_name11 from public.lga_2015_aust"
    url = "https://stevage.cartodb.com/api/v2/sql?q=#{URI.encode query}"

    puts "Fetching #{url}"
    File.open(path, "w") {|f| f.puts open(url).read }
    puts "Done"
  end

  desc "Generate SQL to insert/update production data" 
  task :generate_sql => :environment do
    states = {
      "South Australia" => "SA",
      "Queensland" => "QLD",
      "Northern Territory" => "NT",
      "Australian Capital Territory" => "ACT",
      "New South Wales" => "NSW",
      "Victoria" => "VIC",
      "Western Australia" => "WA",
      "Tasmania" => "TAS"
    }

    inserts = []
    updates = {}

    records = JSON.parse(File.read(path))["rows"]
    records.each do |lga|
      next if lga["lga_name15"].match /(No usual address|Unincorporated)/

      short_name = generate_shortname(lga["lga_name15"])
      human_name = lga["lga_name15"].split(" (").first
      authority = Authority.where(lga_name15: lga["lga_name15"]).first
      authority ||= Authority.where(short_name: short_name, state: states[lga["ste_name11"]]).first

      unless authority
        inserts << "INSERT INTO authorities(full_name, short_name, lga_name15, state) VALUES('#{human_name}', '#{short_name}', '#{lga["lga_name15"]}', '#{states[lga["ste_name11"]]}');"
      else
        updates[authority.state] ||= {}
        updates[authority.state][authority.full_name] = "UPDATE authorities SET lga_name15 = '#{lga["lga_name15"]}') WHERE id = #{authority.id};"
      end
    end

    puts "# Inserts - These *most likely* aren't a match to any existing authority"
    inserts.each{|sql| puts sql}

    puts "# Updates - These are probably the same as the described council"
    states.values.each do |state|
      updates[state].keys.each do |council|
        puts updates[state][council] + " # #{council}, #{state}"
      end
    end
  end

  desc "Bootstrap"
  task :bootstrap => [:fetch_lgas, :load_lgas]
end
