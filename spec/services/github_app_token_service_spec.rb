# frozen_string_literal: true

require "spec_helper"

describe GithubAppTokenService do
  # A real key, so that the JWT signing path actually runs rather than being stubbed out
  let(:private_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:app_client) { instance_double(Octokit::Client) }
  let(:expires_at) { 1.hour.from_now }
  # A real Sawyer::Resource rather than a double, because it resolves its attributes
  # through method_missing and so can't be verified
  let(:token_response) do
    Sawyer::Resource.new(
      Sawyer::Agent.new("https://api.github.com"),
      { token: "ghs_installationtoken", expires_at: }
    )
  end

  before do
    # The service caches the token on the class, so clear it out between examples
    described_class.instance_variable_set(:@cached_token, nil)

    allow(Rails.application.credentials).to receive(:dig).and_call_original
    allow(Rails.application.credentials).to receive(:dig).with(:github_app, :id).and_return(4480419)
    allow(Rails.application.credentials).to receive(:dig).with(:github_app, :installation_id).and_return(151_098_723)
    allow(Rails.application.credentials).to receive(:dig).with(:github_app, :private_key).and_return(private_key.to_pem)

    allow(Octokit::Client).to receive(:new).and_return(app_client)
    allow(app_client).to receive(:create_app_installation_access_token).and_return(token_response)
  end

  describe ".call" do
    it "returns the installation access token" do
      expect(described_class.call).to eq "ghs_installationtoken"
    end

    it "authenticates to github with a JWT signed by the app's private key" do
      described_class.call

      expect(Octokit::Client).to have_received(:new) do |bearer_token:|
        payload, header = JWT.decode(bearer_token, private_key.public_key, true, algorithm: "RS256")
        expect(header["alg"]).to eq "RS256"
        expect(payload["iss"]).to eq 4480419
      end
    end

    it "asks for a token for the right installation" do
      described_class.call

      expect(app_client).to have_received(:create_app_installation_access_token).with(151_098_723)
    end

    it "reuses the token while it is still valid" do
      first_token = described_class.call

      expect(described_class.call).to eq first_token
      expect(app_client).to have_received(:create_app_installation_access_token).once
    end

    context "when the cached token is about to expire" do
      let(:expires_at) { 2.minutes.from_now }

      it "gets a new one" do
        described_class.call
        described_class.call

        expect(app_client).to have_received(:create_app_installation_access_token).twice
      end
    end

    context "when the cached token has already expired" do
      let(:expires_at) { 1.minute.ago }

      it "gets a new one" do
        described_class.call
        described_class.call

        expect(app_client).to have_received(:create_app_installation_access_token).twice
      end
    end

    context "when a credential is missing" do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:github_app, :private_key).and_return(nil)
      end

      it "says which credential and how to set it" do
        expect { described_class.call }
          .to raise_error(/github_app\.private_key is not set in the test Rails credentials/)
      end
    end
  end

  describe GithubAppTokenService::InstallationToken do
    it "keeps the token out of inspect output so that it can't leak into a log" do
      token = described_class.new(token: "ghs_secret", expires_at: 1.hour.from_now)

      expect(token.inspect).not_to include "ghs_secret"
      expect(token.inspect).to include "[FILTERED]"
    end
  end
end
