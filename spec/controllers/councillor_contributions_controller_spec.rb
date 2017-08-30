require 'spec_helper'

describe CouncillorContributionsController do
  let(:authority) { create(:authority, full_name: "Casey City Council") }
  let(:councillor_contribution) { create(:councillor_contribution, authority: authority) }

  context "when the feature flag is on" do
    around do |test|
      with_modified_env CONTRIBUTE_COUNCILLORS_ENABLED: "true" do
        test.run
      end
    end

    before :each do
      create(
        :suggested_councillor,
        name: "Mila Gilic",
        email: "mgilic@casey.vic.gov.au",
        councillor_contribution: councillor_contribution
      )
    end

    describe "#show" do
      it "download csv file" do
        get :show, authority_id: authority.id, id: councillor_contribution.id, format: "csv"
        response_csv = CSV.parse(response.body)
        expect((response_csv).first).to eql [
          "name", "start_date", "end_date", "exective", "council", "council_website",
          "id","email", "image", "party", "source", "ward", "phone_mobile"
        ]
        expect(response_csv.last).to eql [
          "Mila Gilic", nil, nil,nil,"Casey City Council",nil,
          "casey_city_council/mila_gilic", "mgilic@casey.vic.gov.au", nil, nil, nil, nil, nil, nil
          ]
      end
    end
  end
end
