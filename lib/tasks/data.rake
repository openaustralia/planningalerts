namespace :data do
  require 'open-uri'
  require 'json'

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

  path = File.dirname(__FILE__) + "/../../tmp/lga_2015_aust.geojson"

  desc "Fetch ABS LGA data"
  task :fetch_lgas do
    # If we want to load in geometry: the_geom or the_geom_webmercator
    query = "select cartodb_id, lga_name15, ste_name11 from public.lga_2015_aust"
    url = "https://stevage.cartodb.com/api/v2/sql?q=#{URI.encode query}"

    puts "Fetching #{url}"
    File.open(path, "w") {|f| f.puts open(url).read }
    puts "Done"
  end

  desc "Load ABS LGA data" 
  task :load_lgas => :environment do
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

    records = JSON.parse(File.read(path))["rows"]
    records.each do |lga|
      next if lga["lga_name15"].match /(No usual address|Unincorporated)/

      short_name = generate_shortname(lga["lga_name15"])

      authority = Authority.where(lga_name15: lga["lga_name15"]).first
      authority ||= Authority.where(short_name: short_name, state: states[lga["ste_name11"]]).first
      authority ||= Authority.new
      authority.full_name ||= lga["lga_name15"]
      authority.short_name ||= short_name
      authority.lga_name15 ||= lga["lga_name15"]
      authority.state ||= states[lga["ste_name11"]]
      authority.save

      puts "#{authority.short_name}: #{authority.full_name} #{authority.state}"
    end
  end

  desc "Bootstrap"
  task :bootstrap => [:fetch_lgas, :load_lgas]
end
