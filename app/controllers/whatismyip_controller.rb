# typed: strict
# frozen_string_literal: true

# Diagnostic for the Cloudflare/ALB trust boundary: reports the IP Rails sees for the
# request, to aid checking Cloudflare proxying with a one-line curl rather than a real
# sign-in or a log dig. Off by default behind the provide_whatismyip feature flag, since an
# open endpoint would let anyone check whether a forged CF-Connecting-IP is being trusted.
class WhatismyipController < ApplicationController
  extend T::Sig

  before_action :check_enabled

  sig { void }
  def index
    ip = request.remote_ip
    cloudflare_ranges = CloudflareIpRangesService.call
    ip += if cloudflare_ranges.nil?
            " UNABLE TO CHECK"
          elsif cloudflare_ip?(ip, cloudflare_ranges)
            " FAIL"
          else
            ""
          end
    render plain: ip
  end

  private

  sig { void }
  def check_enabled
    head :not_found unless Flipper.enabled?(:provide_whatismyip)
  end

  sig { params(ip: String, cloudflare_ranges: T::Array[IPAddr]).returns(T::Boolean) }
  def cloudflare_ip?(ip, cloudflare_ranges)
    cloudflare_ranges.any? { |range| range.include?(IPAddr.new(ip)) }
  rescue IPAddr::Error
    false
  end
end
