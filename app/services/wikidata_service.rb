# typed: strict
# frozen_string_literal: true

module WikidataService
  extend T::Sig

  # ids for the classes of LGA areas for each state
  LGA_STATES = T.let(%w[Q1426035 Q55557858 Q55558027 Q55558200 Q55593624 Q55671590 Q55687066].freeze, T::Array[String])

  # Given an official website for an LGA return the wikidata ID
  sig { params(url: String).returns(T.nilable(String)) }
  def self.id_from_website(url)
    # Just doing the lookup by domain so that we can handle variants of the url (http/https and ending in "/")
    domain = URI.parse(url).host
    sparql = SPARQL::Client.new("https://query.wikidata.org/sparql")
    # The query build for sparql-client doesn't seem to generate code that wikidata like when using union.
    # So instead create the query by hand
    query = sparql.query("SELECT * WHERE { ?item wdt:P31 ?parent { ?item wdt:P856 <http://#{domain}> . } UNION { ?item wdt:P856 <http://#{domain}/> . } UNION { ?item wdt:P856 <https://#{domain}> . } UNION { ?item wdt:P856 <https://#{domain}/> . } }")
    # In the case where we get several results just restrict it to LGAs
    query.select! { |q| LGA_STATES.include?(q[:parent].to_s.split("/").last) } if query.count > 1

    if query.count.zero?
      return
    elsif query.count > 1
      raise "More than one found"
    end

    entity_url = query.first[:item].to_s
    entity_url.split("/").last
  end

  sig { params(id: String).returns(T::Boolean) }
  def self.lga?(id)
    # rubocop:disable Rails/DynamicFindBy
    item = Wikidata::Item.find_by_id(id)
    # rubocop:enable Rails/DynamicFindBy
    # instance of
    ids = item.claims_for_property_id("P31").map { |claim| claim.mainsnak.value.entity.id }
    ids.any? { |i| LGA_STATES.include?(i) }
  end
end
