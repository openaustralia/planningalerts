# typed: strict
# frozen_string_literal: true

# The website hostname matching an API hostname, e.g. api-idle.planningalerts.org.au
# to www-idle.planningalerts.org.au. Website hostnames come back unchanged.
module WebsiteHost
  extend T::Sig

  sig { params(hostname: String).returns(String) }
  def self.for(hostname)
    hostname.sub(/\Aapi/, "www")
  end
end
