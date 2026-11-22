# frozen_string_literal: true

require "spec_helper"

RSpec.describe ApiKeyPolicy, type: :policy do
  subject { described_class }

  let(:user) { create(:confirmed_user) }

  # The controller limits people to one key, so the policy lets anyone
  # signed in try
  %i[create? confirm?].each do |action|
    permissions action do
      it { is_expected.to permit(user, ApiKey) }
    end
  end

  describe "scope" do
    it "only includes the person's own keys" do
      own_key = create(:api_key, user:)
      create(:api_key, user: create(:confirmed_user))

      expect(described_class::Scope.new(user, ApiKey).resolve).to contain_exactly(own_key)
    end
  end
end
