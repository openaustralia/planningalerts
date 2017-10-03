require 'spec_helper'

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
      let(:councillor_contribution) do
        create(:councillor_contribution, authority: authority, source: "Foo bar source", reviewed: true)
      end
      before :each do
        create(
          :suggested_councillor,
          name: "Mila Gilic",
          email: "mgilic@casey.vic.gov.au",
          councillor_contribution: councillor_contribution
        )
      end

      it "returns a valid CSV file with the contribution" do
        get :show, authority_id: authority.id, id: councillor_contribution.id, format: "csv"

        response_csv = CSV.parse(response.body)
        expect((response_csv).first).to eql [
          "name", "start_date", "end_date", "exective", "council", "council_website",
          "id","email", "image", "party", "source", "ward", "phone_mobile"
        ]
        expect(response_csv.last).to eql [
          "Mila Gilic", nil, nil, nil, "Casey City Council", "http://www.casey.vic.gov.au",
          "casey_city_council/mila_gilic", "mgilic@casey.vic.gov.au", nil, nil, nil, "Foo bar source", nil, nil
          ]
      end
    end

    describe "#index" do
      it "renders reviewed councillor contributions in json format in reverse chronological order" do
        create(
          :councillor_contribution,
          id: 3,
          authority: authority,
          source: "Foo bar source",
          reviewed: true,
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

      it "doesn't include unrevied contributions" do
        create(
          :councillor_contribution,
          source: "not reviewed",
          reviewed: false
        )

        get :index, format: "json"

        expect(response.body).to_not include "not revieved"
        expect(JSON.parse(response.body).count).to be_zero
      end
    end
  end
end
