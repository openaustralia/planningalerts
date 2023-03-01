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
      population_2011: population_2011(item),
      population_2016: population_2016(item),
      population_2021: population_2021(item),
      asgs_2021: asgs_2021(item),
      full_name: full_name(item)
    }
  end

  sig { params(item: T.untyped).returns(T.nilable(String)) }
  def self.state(item)
    # located in the administrative territorial entity
    claims = item.claims_for_property_id("P131")

    claims.each do |claim|
      state = STATE_MAPPING[claim.mainsnak.value.entity.id]
      return state if state
    end
    nil
  end

  sig { params(item: T.untyped).returns(T.untyped) }
  def self.item_for_council(item)
    claims = item.claims_for_property_id("P194")
    raise "Not handling more than one" if claims.count > 1

    claims.first.mainsnak.value.entity unless claims.empty?
  end

  sig { params(item: T.untyped).returns(T.nilable(String)) }
  def self.website_url_single_item(item)
    # official website
    claims = item.claims_for_property_id("P856")
    if claims.count > 1
      # Find the one with "preferred" rank
      claims = claims.select { |claim| claim.rank == "preferred" }
    end
    raise "Not handling more than one" if claims.count > 1

    claims.first.mainsnak.value.to_s if claims.first
  end

  sig { params(item: T.untyped).returns(T.nilable(String)) }
  def self.website_url(item)
    website_url_single_item(item) || website_url_single_item(item_for_council(item))
  end

  sig { params(item: T.untyped).returns(T.nilable(Integer)) }
  def self.population_2011(item)
    population(item, "Q91632502")
  end

  sig { params(item: T.untyped).returns(T.nilable(Integer)) }
  def self.population_2016(item)
    population(item, "Q33128519")
  end

  sig { params(item: T.untyped).returns(T.nilable(Integer)) }
  def self.population_2021(item)
    population(item, "Q60745365")
  end

  sig { params(item: T.untyped, determination_method: String).returns(T.nilable(Integer)) }
  def self.population(item, determination_method)
    # population
    claim_census = item.claims_for_property_id("P1082").find do |claim|
      # determination method
      qualifiers = claim.qualifiers["P459"]
      next unless qualifiers

      qualifiers.any? do |qualifier|
        qualifier.datavalue.value.id == determination_method
      end
    end
    return if claim_census.nil?

    raise "Unexpected type" unless claim_census.mainsnak.value.type == "quantity"

    raise "Unexpected unit" unless claim_census.mainsnak.value.value.unit == "1"

    claim_census.mainsnak.value.value.amount.to_i
  end

  # Australian Statistical Geography 2021 ID
  sig { params(item: T.untyped).returns(T.nilable(String)) }
  def self.asgs_2021(item)
    claims = item.claims_for_property_id("P10112")
    raise "Unexpected number of claims" if claims.count > 1

    claims.first.mainsnak.value.to_s if claims.first
  end

  sig { params(item: T.untyped).returns(T.nilable(String)) }
  def self.full_name(item)
    item_for_council(item)&.label
  end
end