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
    return if query.count.zero?

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

  sig { params(id: String).returns(T.untyped) }
  def self.get_data(id)
    # rubocop:disable Rails/DynamicFindBy
    item = Wikidata::Item.find_by_id(id)
    # rubocop:enable Rails/DynamicFindBy
    {
      state: state(item),
      website_url: website_url(item),
      population_2011: population_2011(item)
    }
  end

  sig { params(item: T.untyped).returns(T.nilable(String)) }
  def self.state(item)
    # located in the administrative territorial entity
    claims = item.claims_for_property_id("P131")
    raise "Not handling more than one" if claims.count > 1

    STATE_MAPPING[claims.first.mainsnak.value.entity.id]
  end

  sig { params(item: T.untyped).returns(T.nilable(String)) }
  def self.website_url(item)
    # official website
    claims = item.claims_for_property_id("P856")
    raise "Not handling more than one" if claims.count > 1

    website_url = claims.first.mainsnak.value.to_s if claims.first
    if website_url.nil?
      # See if the council has the website information
      # legislative body
      claims = item.claims_for_property_id("P194")
      raise "Not handling more than one" if claims.count > 1

      claims = claims.first.mainsnak.value.entity.claims_for_property_id("P856")
      raise "Not handling more than one" if claims.count > 1

      website_url = claims.first.mainsnak.value.to_s if claims.first
    end
    website_url
  end

  sig { params(item: T.untyped).returns(T.nilable(Integer)) }
  def self.population_2011(item)
    # population
    claims = item.claims_for_property_id("P1082")
    # determination method
    qualifiers = claims.first.qualifiers["P459"]
    raise "Don't expect more than one determination method" if qualifiers.count > 1

    claim_census_2011 = claims.find do |claim|
      qualifiers = claim.qualifiers["P459"]
      raise "Don't expect more than one determination method" if qualifiers.count > 1

      qualifiers.first.datavalue.value.id == "Q91632502"
    end

    raise "Unexpected type" unless claim_census_2011.mainsnak.value.type == "quantity"

    raise "Unexpected unit" unless claim_census_2011.mainsnak.value.value.unit == "1"

    claim_census_2011.mainsnak.value.value.amount.to_i
  end
end
