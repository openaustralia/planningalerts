# frozen_string_literal: true

namespace :planningalerts do
  # Updates:
  # * state
  # * population
  # * website_url
  # * asgs (ABS code for LGA)
  desc "Update authorities from wikidata"
  task update_authorities_from_wikidata: :environment do
    data = WikidataService.all_data
    Authority.active.find_each do |authority|
      if authority.wikidata_id.blank?
        puts "Skipping #{authority.full_name} because wikidata_id is blank"
        next
      end

      row = data[authority.wikidata_id]
      raise "wikidata_id for #{authority.full_name} does not point to an LGA" if row.nil?

      puts "#{authority.full_name} - state: #{authority.state} => #{row[:state]}" if row[:state] != authority.state
      puts "#{authority.full_name} - population_2021: #{authority.population_2021} => #{row[:population_2021]}" if row[:population_2021] != authority.population_2021
      puts "#{authority.full_name} - website_url: #{authority.website_url} => #{row[:website_url]}" if row[:website_url] != authority.website_url
      puts "#{authority.full_name} - asgs_2021: #{authority.asgs_2021} => #{row[:asgs_2021]}" if row[:asgs_2021] != authority.asgs_2021
      authority.update!(
        state: row[:state],
        population_2021: row[:population_2021],
        website_url: row[:website_url],
        asgs_2021: row[:asgs_2021]
      )
    end
  end

  desc "Read shapefile"
  task read_shapefile: :environment do
    require "zip"

    unless File.exist?("tmp/boundaries/LGA_2022_AUST_GDA94.shp")
      puts "Downloading shapefile..."
      FileUtils.mkdir_p("tmp/boundaries")
      URI.open("https://www.abs.gov.au/statistics/standards/australian-statistical-geography-standard-asgs-edition-3/jul2021-jun2026/access-and-downloads/digital-boundary-files/LGA_2022_AUST_GDA94_SHP.zip") do |f|
        zip_stream = Zip::InputStream.new(f)
        while (entry = zip_stream.get_next_entry)
          # Extract into tmp/boundaries directory
          entry.extract("tmp/boundaries/#{entry.name}")
        end
      end
    end

    # See http://www.geoproject.com.au/gda.faq.html
    # "What is the difference between GDA94 and WGS84?"
    # Difference between GDA94 and WGS84 is going to be of the order of a metre
    # or so so we can probably just ignore the difference for the time being
    # TODO: Properly support the conversion

    # We're just loading the GDA94 as if it's WGS84 (srid 4326)
    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    RGeo::Shapefile::Reader.open("tmp/boundaries/LGA_2022_AUST_GDA94.shp", factory:) do |file|
      file.each do |record|
        # First get the LGA code for the current record
        asgs_2021 = "LGA#{record.attributes['LGA_CODE22']}"
        # Lookup the associated authority
        authority = Authority.find_by(asgs_2021:)
        # We expect there to be more authorities included in the shapefile
        # then we have in PlanningAlerts currently. So, just silently ignore
        # if we can't find it.
        next if authority.nil?

        puts "Loading boundary for #{authority.full_name}..."
        authority.update!(boundary: record.geometry)
      end
    end
  end

  namespace :emergency do
    desc "Regenerates all the counter caches in case they got out of synch"
    task fixup_counter_caches: :environment do
      Comment.counter_culture_fix_counts
    end
  end

  namespace :migrate do
    desc "Update lonlat on applications"
    task update_lonlat_on_applications: :environment do
      ActiveRecord::Base.connection.execute("UPDATE applications SET lonlat = ST_POINT(lng, lat) WHERE lonlat IS NULL")
    end
  end
end
