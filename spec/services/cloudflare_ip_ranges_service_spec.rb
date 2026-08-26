# frozen_string_literal: true

require "spec_helper"

describe CloudflareIpRangesService do
  describe ".call" do
    context "when the ranges are already cached" do
      before do
        allow(Rails.cache).to receive(:fetch).and_return(["173.245.48.0/20", "2400:cb00::/32"])
      end

      it "returns the cached ranges as IPAddr instances" do
        expect(described_class.call).to eq [IPAddr.new("173.245.48.0/20"), IPAddr.new("2400:cb00::/32")]
      end
    end

    context "when the ranges are not yet cached" do
      # config.cache_store is :null_store in test, so Rails.cache.fetch always runs its
      # block, which is what we want to exercise here
      before do
        allow(HTTParty).to receive(:get)
          .with("https://www.cloudflare.com/ips-v4")
          .and_return(instance_double(HTTParty::Response, body: "173.245.48.0/20\n"))
        allow(HTTParty).to receive(:get)
          .with("https://www.cloudflare.com/ips-v6")
          .and_return(instance_double(HTTParty::Response, body: "2400:cb00::/32\n"))
      end

      it "fetches and parses Cloudflare's published IPv4 and IPv6 ranges" do
        expect(described_class.call).to eq [IPAddr.new("173.245.48.0/20"), IPAddr.new("2400:cb00::/32")]
      end
    end
  end
end
