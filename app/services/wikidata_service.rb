# typed: strict
# frozen_string_literal: true

module WikidataService
  extend T::Sig

  LGA_STATE_MAPPING = T.let({
    "Q1426035" => "VIC",
    "Q55557858" => "WA",
    "Q55558027" => "SA",
    "Q55558200" => "NSW",
    "Q55593624" => "QLD",
    "Q55671590" => "NT",
    "Q55687066" => "TAS"
  }.freeze, T::Hash[String, String])

  sig { returns(SPARQL::Client) }
  def self.client
    SPARQL::Client.new("https://query.wikidata.org/sparql")
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
end
