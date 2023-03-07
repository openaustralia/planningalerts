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

    factory = RGeo::Geographic.spherical_factory(srid: 4283)
    RGeo::Shapefile::Reader.open("tmp/boundaries/LGA_2022_AUST_GDA94.shp", factory:) do |file|
      puts "File contains #{file.num_records} records."
      file.each do |record|
        puts "Record number #{record.index}:"
        # puts "  Geometry: #{record.geometry.as_text}"
        puts "  Attributes: #{record.attributes.inspect}"
      end
    end
  end

  namespace :emergency do
    desc "Regenerates all the counter caches in case they got out of synch"
    task fixup_counter_caches: :environment do
      Comment.counter_culture_fix_counts
    end
  end
end
