# typed: strict
# frozen_string_literal: true

require "ipaddr"

# Cloudflare's published edge IP ranges, used by WhatismyipController to check whether a
# request's remote_ip has already been rewritten from a Cloudflare edge address to the real
# visitor address.
class CloudflareIpRangesService
  extend T::Sig

  RANGE_URLS = T.let(
    [
      "https://www.cloudflare.com/ips-v4",
      "https://www.cloudflare.com/ips-v6"
    ].freeze,
    T::Array[String]
  )

  # Cloudflare currently publishes about 15 IPv4 and 7 IPv6 ranges. Treat anything short of
  # this as a broken response (an error page, a truncated body) rather than a real shrinking
  # of Cloudflare's network, so we don't cache and act on it for a day.
  MIN_EXPECTED_ENTRIES_PER_RANGE = 4

  # Returns nil if the ranges can't be reliably determined right now
  sig { returns(T.nilable(T::Array[IPAddr])) }
  def self.call
    new.call
  end

  sig { returns(T.nilable(T::Array[IPAddr])) }
  def call
    cidrs&.map { |cidr| IPAddr.new(cidr) }
  end

  private

  # Cached a day so this doesn't depend on cloudflare.com being reachable on every check.
  # skip_nil so a failed fetch isn't cached, and gets retried on the next request instead.
  sig { returns(T.nilable(T::Array[String])) }
  def cidrs
    Rails.cache.fetch("cloudflare_ip_ranges_service/v1", expires_in: 1.day, skip_nil: true) do
      cidr_lists = RANGE_URLS.map { |url| fetch_cidr_list(url) }
      cidr_lists.flatten unless cidr_lists.any?(&:nil?)
    end
  end

  # Returns nil if the response wasn't a usable CIDR list. Network-level failures (timeouts, DNS,
  # a dropped or reset connection, a bad TLS handshake) are rescued here too, alongside the
  # non-200/too-short checks above, so a Cloudflare outage degrades to "can't check" rather than
  # an unhandled 500 out of the controller. Programming errors are deliberately left unrescued.
  sig { params(url: String).returns(T.nilable(T::Array[String])) }
  def fetch_cidr_list(url)
    response = HTTParty.get(url)
    return nil unless response.code == 200

    cidrs = response.body.lines.map(&:strip).reject(&:empty?)
    cidrs if cidrs.size >= MIN_EXPECTED_ENTRIES_PER_RANGE
  rescue Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError, EOFError, Net::ProtocolError,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError
    nil
  end
end
