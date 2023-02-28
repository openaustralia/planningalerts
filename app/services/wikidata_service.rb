# typed: strict
# frozen_string_literal: true

module WikidataService
  extend T::Sig

  # ids for the classes of LGA areas for each state
  LGA_STATE_IDS = T.let(%w[Q1426035 Q55557858 Q55558027 Q55558200 Q55593624 Q55671590 Q55687066].freeze, T::Array[String])
  LOCAL_GOVERNMENT_IDS = T.let(%w[Q3308596 Q6501447].freeze, T::Array[String])

  # Given an official website for an LGA return the wikidata ID
  sig { params(url: String).returns(T.nilable(String)) }
  def self.id_from_website(url)
    # Just doing the lookup by domain so that we can handle variants of the url (http/https and ending in "/")
    domain = URI.parse(url).host
    sparql = SPARQL::Client.new("https://query.wikidata.org/sparql")
    # The query build for sparql-client doesn't seem to generate code that wikidata likes when using multiple values.
    # So instead create the query by hand
    url_values = ["http://#{domain}", "http://#{domain}/", "https://#{domain}", "https://#{domain}/"].map { |u| "<#{u}>" }
    parent_values = (LGA_STATE_IDS + LOCAL_GOVERNMENT_IDS).map { |id| "wd:#{id}" }
    query = sparql.query(
      "SELECT * WHERE " \
      "{ " \
      "VALUES ?url { #{url_values.join(' ')} } " \
      "VALUES ?parent { #{parent_values.join(' ')} } " \
      "?item wdt:P856 ?url.  " \
      "?item wdt:P31 ?parent. " \
      "}"
    )
    # Limit to one result per item
    items = {}
    query.each { |q| items[q[:item].to_s] = q }
    query = items.values

    # In the case where we get several results just restrict it to LGAs
    query.select! { |q| LGA_STATE_IDS.include?(q[:parent].to_s.split("/").last) } if query.count > 1

    if query.count.zero?
      return
    elsif query.count > 1
      raise "More than one found"
    end

    entity_url = query.first[:item].to_s
    entity_url.split("/").last
  end

  # Given an id finds the id of the related LGA
  # If the given id is an LGA it returns the same id
  # If the LGA can't be found returns nil
  sig { params(id: String).returns(T.nilable(String)) }
  def self.lga(id)
    # rubocop:disable Rails/DynamicFindBy
    item = Wikidata::Item.find_by_id(id)
    # rubocop:enable Rails/DynamicFindBy
    # instance of
    ids = item.claims_for_property_id("P31").map { |claim| claim.mainsnak.value.entity.id }
    if ids.any? { |i| LGA_STATE_IDS.include?(i) }
      # We're already on an LGA so return the original id
      id
    else
      # applies to jurisdiction
      claims = item.claims_for_property_id("P1001")
      raise "Don't expect more than one jurisdiction" if claims.count > 1

      return if claims.empty?

      claims.first.mainsnak.value.entity.id
    end
  end
end
