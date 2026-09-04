# frozen_string_literal: true

require "spec_helper"

describe PostalSigningKeysService do
  let(:signing_key) { OpenSSL::PKey::RSA.new(2048) }

  def pems
    described_class.call&.map(&:to_pem)
  end

  it "returns the key postal publishes" do
    stub_jwks(body: jwks_json(signing_key.public_key))
    expect(pems).to eq [signing_key.public_key.to_pem]
  end

  it "ignores a key that isn't for signatures" do
    stub_jwks(body: { "keys" => [jwk(signing_key.public_key, use: "enc")] }.to_json)
    expect(pems).to be_nil
  end

  it "accepts a key with no use, which the format allows" do
    stub_jwks(body: { "keys" => [jwk(signing_key.public_key, use: nil)] }.to_json)
    expect(pems).to eq [signing_key.public_key.to_pem]
  end

  it "ignores a key that isn't RSA" do
    stub_jwks(body: { "keys" => [{ "kty" => "oct", "k" => "c2VjcmV0", "use" => "sig" }] }.to_json)
    expect(pems).to be_nil
  end

  it "returns nil on a non-200" do
    stub_jwks(body: jwks_json(signing_key.public_key), code: 502)
    expect(pems).to be_nil
  end

  it "returns nil when the body isn't json" do
    stub_jwks(body: "<html>Bad gateway</html>")
    expect(pems).to be_nil
  end

  it "returns nil when the body isn't an object" do
    stub_jwks(body: "[1, 2]")
    expect(pems).to be_nil
  end

  it "returns nil when there's no keys member" do
    stub_jwks(body: { "foo" => "bar" }.to_json)
    expect(pems).to be_nil
  end

  it "returns nil when the keys member isn't a list" do
    stub_jwks(body: { "keys" => "nope" }.to_json)
    expect(pems).to be_nil
  end

  it "returns nil when a key's modulus is malformed" do
    stub_jwks(body: { "keys" => [jwk(signing_key.public_key).merge("n" => "!!!!")] }.to_json)
    expect(pems).to be_nil
  end

  it "returns nil when a key's modulus isn't a string" do
    stub_jwks(body: { "keys" => [jwk(signing_key.public_key).merge("n" => 123)] }.to_json)
    expect(pems).to be_nil
  end

  [Net::OpenTimeout.new, SocketError.new, Errno::ECONNRESET.new, OpenSSL::SSL::SSLError.new,
   EOFError.new, Net::HTTPBadResponse.new].each do |error|
    it "returns nil rather than let a #{error.class} escape" do
      allow(HTTParty).to receive(:get).and_raise(error)
      expect(pems).to be_nil
    end
  end

  # Bounding these fetches is the whole point: /postal/event is unauthenticated, so without a
  # cached copy anyone could turn each request they send into an outbound request of ours.
  # config.cache_store is :null_store in test, so these examples need a real one.
  describe "caching" do
    around do |example|
      original = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      example.run
      Rails.cache = original
    end

    it "fetches the published keys once however many times it's asked" do
      stub_jwks(body: jwks_json(signing_key.public_key))
      2.times { described_class.call }
      expect(HTTParty).to have_received(:get).once
    end

    it "doesn't retry a failed fetch on the very next request" do
      allow(HTTParty).to receive(:get).and_raise(Net::OpenTimeout)
      2.times { described_class.call }
      expect(HTTParty).to have_received(:get).once
    end

    it "fetches again once the cached copy has expired" do
      stub_jwks(body: jwks_json(signing_key.public_key))
      described_class.call
      Timecop.travel(16.minutes.from_now) { described_class.call }
      expect(HTTParty).to have_received(:get).twice
    end
  end
end
