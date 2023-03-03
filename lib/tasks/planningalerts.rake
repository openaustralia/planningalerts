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

  namespace :emergency do
    desc "Regenerates all the counter caches in case they got out of synch"
    task fixup_counter_caches: :environment do
      Comment.counter_culture_fix_counts
    end
  end
end
