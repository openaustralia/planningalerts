# typed: strict
# frozen_string_literal: true

module WikidataService
  extend T::Sig

  # ids for the classes of LGA areas for each state
  LGA_VIC = "Q1426035"
  LGA_WA = "Q55557858"
  LGA_SA = "Q55558027"
  LGA_NSW = "Q55558200"
  LGA_QLD = "Q55593624"
  LGA_NT = "Q55671590"
  LGA_TAS = "Q55687066"
  LGA_STATE_MAPPING = T.let({
    LGA_VIC => "VIC",
    LGA_WA => "WA",
    LGA_SA => "SA",
    LGA_NSW => "NSW",
    LGA_QLD => "QLD",
    LGA_NT => "NT",
    LGA_TAS => "TAS"
  }.freeze, T::Hash[String, String])
  LGA_STATE_IDS = T.let([LGA_VIC, LGA_WA, LGA_SA, LGA_NSW, LGA_QLD, LGA_NT, LGA_TAS].freeze, T::Array[String])
  LOCAL_GOVERNMENT_IDS = T.let(%w[Q3308596 Q6501447].freeze, T::Array[String])
  STATE_MAPPING = T.let({ "Q3258" => "ACT",
                          "Q3224" => "NSW",
                          "Q3235" => "NT",
                          "Q36074" => "QLD",
                          "Q35715" => "SA",
                          "Q34366" => "TAS",
                          "Q36687" => "VIC",
                          "Q3206" => "WA" }.freeze, T::Hash[String, String])

  sig { params(url: String).returns(T.nilable(String)) }
  def self.lga_id_from_website(url)
    id = id_from_website(url)
    return if id.nil?

    lga(id)
  end

  sig { returns(SPARQL::Client) }
  def self.client
    SPARQL::Client.new("https://query.wikidata.org/sparql")
  end

  # Given an official website for an LGA return the wikidata ID
  sig { params(url: String).returns(T.nilable(String)) }
  def self.id_from_website(url)
    # Just doing the lookup by domain so that we can handle variants of the url (http/https and ending in "/")
    domain = URI.parse(url).host
    sparql = client
    # The query build for sparql-client doesn't seem to generate code that wikidata likes when using multiple values.
    # So instead create the query by hand
    url_values = ["http://#{domain}", "http://#{domain}/", "https://#{domain}", "https://#{domain}/"].map { |u| "<#{u}>" }
    parent_values = (LGA_STATE_IDS + LOCAL_GOVERNMENT_IDS).map { |id| "wd:#{id}" }
    query = sparql.query(%(
      SELECT * WHERE
      {
        VALUES ?url { #{url_values.join(' ')} }
        VALUES ?parent { #{parent_values.join(' ')} }
        ?item wdt:P856 ?url.
        ?item wdt:P31 ?parent.
        # Not a former local government area of Australia
        MINUS { ?item wdt:P31 wd:Q30129411. }
      }
    ))
    return if query.count.zero?

    entity_url = query.first[:item].to_s
    entity_url.split("/").last
  end

  # Get the data for all authorities at once
  sig { returns(T::Hash[String, T::Hash[Symbol, T.untyped]]) }
  def self.all_data
    # This lists all the LGAs I hope. I think it returns roughly 10 less than the official numbers that
    # I can see from the ABS
    query = client.query(%(
      SELECT ?lga ?lga_state ?lga_website ?council_website ?population_2021 ?asgs_2021 WHERE {
        # subclass of local government area of Australia
        ?lga_state wdt:P279 wd:Q1867183.
        # instance of
        ?lga wdt:P31 ?lga_state
        # NOT instance of former local government area of Australia
        MINUS { ?lga wdt:P31 wd:Q30129411. }
        # official website
        OPTIONAL { ?lga wdt:P856 ?lga_website }
        # legislative body / official website
        OPTIONAL { ?lga wdt:P194/wdt:P856 ?council_website }
        OPTIONAL {
          # population
          ?lga p:P1082 ?statement.
          # determination method Australian Census 2021
          ?statement pq:P459 wd:Q60745365.
          ?statement ps:P1082 ?population_2021.
        }
        # Australian Statistical Geography 2021 ID
        OPTIONAL { ?lga wdt:P10112 ?asgs_2021 }
      }
    ))
    result = {}
    query.each do |s|
      result[s[:lga].to_s.split("/").last] = {
        state: LGA_STATE_MAPPING[s[:lga_state].to_s.split("/").last],
        website_url: (s[:lga_website] || s[:council_website])&.to_s,
        population_2021: s[:population_2021]&.to_i,
        asgs_2021: s[:asgs_2021]&.value
      }
    end
    result
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
