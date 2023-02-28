# frozen_string_literal: true

namespace :planningalerts do
  desc "update wikidata ids"
  task update_wikidata_ids: :environment do
    Authority.active.find_each do |authority|
      next if authority.wikidata_id.present?

      puts "Getting wikidata id for #{authority.full_name} (#{authority.website_url})..."
      wikidata_id = WikidataService.id_from_website(authority.website_url)

      if wikidata_id
        puts wikidata_id
        authority.update!(wikidata_id:)
      else
        puts "WARNING: Couldn't find"
      end
    end
  end

  desc "check wikidata ids point to the correct place"
  task check_wikidata_ids: :environment do
    Authority.active.find_each do |authority|
      if authority.wikidata_id.blank?
        puts "#{authority.full_name} does not have wikidata_id set"
        next
      end

      puts "Looking up #{authority.full_name} wikidata_id #{authority.wikidata_id}..."

      lga_id = WikidataService.lga(authority.wikidata_id)
      if lga_id.nil?
        puts "#{authority.full_name} wikidata_id #{authority.wikidata_id} couldn't find a related LGA"
        next
      end

      if lga_id != authority.wikidata_id
        puts "#{authority.full_name} wikidata_id #{authority.wikidata_id} => #{lga_id}"
        authority.update!(wikidata_id: lga_id)
        next
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
