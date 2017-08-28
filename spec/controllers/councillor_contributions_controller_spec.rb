require 'spec_helper'

describe CouncillorContributionsController do
    let(:authority){create(:authority)}
    let(:councillor_contribution){create(:councillor_contribution, authority: authority)}
    let(:suggested_councillors){create(:suggested_councillor, councillor_contribution: councillor_contribution)}

    context "when the feature flag is on" do
      around do |test|
        with_modified_env CONTRIBUTE_COUNCILLORS_ENABLED: "true" do
          test.run
        end
      end

    describe "#show" do
      it "download csv file" do
        get :show, authority_id: authority.id, id: councillor_contribution.id, format: "csv"
        expect(response.header['Content-Type']).to include'text/csv'
        expect(response.body).to include "name,start_date,end_date,exective,council,council_website,id,email,image,party,source,ward,phone_mobile"
      end
    end
  end
end
