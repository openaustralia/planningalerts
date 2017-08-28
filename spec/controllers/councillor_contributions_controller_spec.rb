require 'spec_helper'

describe CouncillorContributionsController do
    let(:authority){create(:authority)}
    let(:councillor_contribution){create(:councillor_contribution, authority: authority)}
    let(:suggested_councillors){create(:suggested_councillor, councillor_contribution: councillor_contribution)}

    
end
