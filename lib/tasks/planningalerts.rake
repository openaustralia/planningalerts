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

  desc "get authority information from wikidata"
  task get_authority_wikidata_data: :environment do
    Authority.active.where.not(wikidata_id: nil).find_each do |authority|
      puts "Looking up #{authority.wikidata_id}..."
      p WikidataService.get_data(authority.wikidata_id)
      exit
    end
  end

  namespace :emergency do
    desc "Regenerates all the counter caches in case they got out of synch"
    task fixup_counter_caches: :environment do
      Comment.counter_culture_fix_counts
    end
  end
end
