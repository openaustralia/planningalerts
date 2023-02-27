# frozen_string_literal: true

# Given an official website for an LGA return the wikidata ID
def wikidata_id_from_website(url)
  # It looks like wikidata always put a "/" on the end of a URL irrespective
  # of whether it was entered like that. So, to match we add a "/" if the url
  # doesn't have one.
  url += "/" if url.last != "/"
  sparql = SPARQL::Client.new("https://query.wikidata.org/sparql")
  query = sparql.select.where([:item, "wdt:P856", RDF::URI.new(url)])
  raise "More than one found!" if query.solutions.count > 1
  return if query.solutions.count.zero?

  entity_url = query.solutions.first[:item].to_s
  entity_url.split("/").last
end

namespace :planningalerts do
  desc "update wikidata ids"
  task update_wikidata_ids: :environment do
    Authority.active.where(wikidata_id: nil).find_each do |authority|
      puts "Getting wikidata id for #{authority.full_name}..."
      wikidata_id = wikidata_id_from_website(authority.website_url)
      if wikidata_id
        puts wikidata_id
        authority.update!(wikidata_id:)
      else
        puts "Couldn't find"
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
