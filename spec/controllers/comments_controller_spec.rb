require 'spec_helper'

describe CommentsController do
  before :each do
    request.env['HTTPS'] = 'on'
  end

  describe "#per_week" do
    let(:authority) { create(:authority, id: 3) }

    it { expect(get(:per_week, authority_id: 3, format: :json)).to be_success }
  end
end
