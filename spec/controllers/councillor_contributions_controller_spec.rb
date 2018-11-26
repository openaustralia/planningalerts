# frozen_string_literal: true

require "spec_helper"

describe CouncillorContributionsController do
  let(:authority) do
    create(:authority, full_name: "Casey City Council", website_url: "http://www.casey.vic.gov.au")
  end

  context "when the feature flag is on" do
    around do |test|
      with_modified_env CONTRIBUTE_COUNCILLORS_ENABLED: "true" do
        test.run
      end
    end

    describe "#show" do
      it "returns a valid CSV file with the contribution" do
        create(
          :suggested_councillor,
          name: "Mila Gilic",
          email: "mgilic@casey.vic.gov.au",
          councillor_contribution: create(
            :councillor_contribution,
            id: 5,
            authority: authority,
            source: "Foo bar source",
            accepted: true
          )
        )

        get :show, params: { authority_id: authority.id, id: 5, format: "csv" }

        response_csv = CSV.parse(response.body)
        expect(response_csv.first).to eql %w[
          name start_date end_date executive council council_website
          id email image party source ward
        ]
        expect(response_csv.last).to eql(
          [
            "Mila Gilic", nil, nil, nil, "Casey City Council", "http://www.casey.vic.gov.au",
            "casey_city_council/mila_gilic", "mgilic@casey.vic.gov.au", nil, nil, "Foo bar source", nil
          ]
        )
      end
    end

    describe "#index" do
      it "renders accepted councillor contributions in json format in reverse chronological order" do
        create(
          :councillor_contribution,
          id: 3,
          authority: authority,
          source: "Foo bar source",
          accepted: true,
          created_at: Time.utc(2017, 9, 30)
        )

        get :index, format: "json"

        expected_json = [
          {
            "councillor_contribution" => {
              "id" => 3,
              "created_at" => "2017-09-30T00:00:00.000Z",
              "source" => "Foo bar source",
              "contributor" => {
                "name" => "Felix Chaung"
              }
            }
          }
        ]
        expect(JSON.parse(response.body)).to eql expected_json
      end

      it "doesn't include contributions that aren't marked accepted" do
        create(
          :councillor_contribution,
          source: "not accepted",
          accepted: false
        )

        get :index, format: "json"

        expect(response.body).to_not include "not accepted"
        expect(JSON.parse(response.body).count).to be_zero
      end
    end
  end
end
