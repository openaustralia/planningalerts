# frozen_string_literal: true

require "spec_helper"

describe CloudflareIpRangesService do
  # Real Cloudflare-published ranges, so the pass/fail examples in whatismyip_controller_spec
  # mean something. Four each, since that's the service's minimum-plausible-list size.
  let(:ipv4_ranges) { "173.245.48.0/20\n103.21.244.0/22\n103.22.200.0/22\n103.31.4.0/22\n" }
  let(:ipv6_ranges) { "2400:cb00::/32\n2606:4700::/32\n2803:f800::/32\n2405:b500::/32\n" }

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
      # block, which is what we want to exercise below
      before do
        allow(HTTParty).to receive(:get)
          .with("https://www.cloudflare.com/ips-v4")
          .and_return(instance_double(HTTParty::Response, code: 200, body: ipv4_ranges))
        allow(HTTParty).to receive(:get)
          .with("https://www.cloudflare.com/ips-v6")
          .and_return(instance_double(HTTParty::Response, code: 200, body: ipv6_ranges))
      end

      it "fetches and parses Cloudflare's published IPv4 and IPv6 ranges" do
        expect(described_class.call).to eq(
          (ipv4_ranges.lines + ipv6_ranges.lines).map { |cidr| IPAddr.new(cidr.strip) }
        )
      end

      it "caches the combined ranges without hitting cloudflare.com on every check" do
        allow(Rails.cache).to receive(:fetch).and_call_original

        described_class.call

        expect(Rails.cache).to have_received(:fetch)
          .with("cloudflare_ip_ranges_service/v1", expires_in: 1.day, skip_nil: true)
      end

      context "when one range comes back with a non-200 status" do
        before do
          allow(HTTParty).to receive(:get)
            .with("https://www.cloudflare.com/ips-v4")
            .and_return(instance_double(HTTParty::Response, code: 502, body: "Bad Gateway"))
        end

        it "returns nil rather than treat the error page as a range list" do
          expect(described_class.call).to be_nil
        end
      end

      context "when one range comes back implausibly short" do
        before do
          allow(HTTParty).to receive(:get)
            .with("https://www.cloudflare.com/ips-v4")
            .and_return(instance_double(HTTParty::Response, code: 200, body: "173.245.48.0/20\n"))
        end

        it "returns nil rather than trust a truncated list" do
          expect(described_class.call).to be_nil
        end
      end
    end
  end
end
