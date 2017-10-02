require 'spec_helper'

describe CouncillorContributionsController do
  let(:authority) do
    create(:authority, full_name: "Casey City Council", website_url: "http://www.casey.vic.gov.au")
  end

  let(:councillor_contribution_not_reviewed) do
    create(:councillor_contribution, authority: authority, source: "not reviewed", reviewed: false)
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
  end
end
