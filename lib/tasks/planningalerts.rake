# frozen_string_literal: true

namespace :planningalerts do
  desc "update wikidata ids"
  task update_wikidata_ids: :environment do
    Authority.active.find_each do |authority|
      next if authority.wikidata_id.present?

      puts "Getting wikidata id for #{authority.full_name} (#{authority.website_url})..."
      wikidata_id = WikidataService.lga_id_from_website(authority.website_url)

      if wikidata_id
        puts wikidata_id
        authority.update!(wikidata_id:)
      else
        puts "WARNING: Couldn't find"
      end
    end
  end

  # Updates:
  # * state
  # * population
  # * website_url
  # TODO: Also update asgs_2021
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
      authority.update!(
        state: row[:state],
        population_2021: row[:population_2021],
        website_url: row[:website_url]
      )
    end
  end

  desc "get authority information from wikidata"
  task get_authority_wikidata_data: :environment do
    data = WikidataService.all_data
    CSV.open("wikidata.csv", "w") do |csv|
      Authority.active.where.not(wikidata_id: nil).order(:wikidata_id).each_with_index do |authority, index|
        row = data[authority.wikidata_id]
        # Merge in exisiting data
        merged = row.merge(
          wikidata_id: authority.wikidata_id,
          authority_state: authority.state,
          authority_website_url: authority.website_url,
          authority_population_2017: authority.population_2017,
          authority_short_name: authority.short_name
        )
        csv << merged.keys if index.zero?
        csv << merged.values
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
