# frozen_string_literal: true

require "spec_helper"

describe WikidataService do
  # Stand in for the Wikidata SPARQL endpoint with one row like it returns
  before do
    row = {
      lga: RDF::URI("http://www.wikidata.org/entity/Q1000001"),
      lga_state: RDF::URI("http://www.wikidata.org/entity/Q55558200"),
      council_website: RDF::URI("https://www.exampleton.nsw.gov.au/"),
      population_2021: RDF::Literal(12_345),
      asgs_2021: RDF::Literal("LGA10001")
    }
    allow(described_class).to receive(:client).and_return(instance_double(SPARQL::Client, query: [row]))
  end

  it "returns each local government area's details by Wikidata id" do
    expect(described_class.all_data).to eq(
      "Q1000001" => {
        state: "NSW",
        website_url: "https://www.exampleton.nsw.gov.au/",
        population_2021: 12_345,
        asgs_2021: "LGA10001"
      }
    )
  end
end
