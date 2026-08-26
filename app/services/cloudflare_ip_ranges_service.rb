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

  sig { returns(T::Array[IPAddr]) }
  def self.call
    new.call
  end

  sig { returns(T::Array[IPAddr]) }
  def call
    cidrs.map { |cidr| IPAddr.new(cidr) }
  end

  private

  # Cached a day so this doesn't depend on cloudflare.com being reachable on every check
  sig { returns(T::Array[String]) }
  def cidrs
    Rails.cache.fetch("cloudflare_ip_ranges_service/v1", expires_in: 1.day) do
      RANGE_URLS.flat_map { |url| HTTParty.get(url).body.lines.map(&:strip).reject(&:empty?) }
    end
  end
end
