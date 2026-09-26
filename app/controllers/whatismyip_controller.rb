# typed: strict
# frozen_string_literal: true

# Reports the IP Rails sees for the request, so the Cloudflare/load balancer trust boundary
# can be checked with a one-line curl rather than a real sign-in or a log dig. Compare the
# answer with an independent checker such as https://whatismyip.akamai.com/ - if they differ,
# remote_ip isn't being unwrapped correctly. Off by default behind the provide_whatismyip
# feature flag, since an open endpoint would let anyone check whether a forged header is
# being trusted.
class WhatismyipController < ApplicationController
  extend T::Sig

  before_action :check_enabled

  sig { void }
  def index
    render plain: request.remote_ip
  end

  private

  sig { void }
  def check_enabled
    head :not_found unless Flipper.enabled?(:provide_whatismyip)
  end
end
