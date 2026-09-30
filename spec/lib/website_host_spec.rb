# frozen_string_literal: true

require "spec_helper"

describe WebsiteHost do
  {
    "api.planningalerts.org.au" => "www.planningalerts.org.au",
    "api-idle.planningalerts.org.au" => "www-idle.planningalerts.org.au",
    "api.pa.org.localhost" => "www.pa.org.localhost",
    "www.planningalerts.org.au" => "www.planningalerts.org.au",
    "www-idle.planningalerts.org.au" => "www-idle.planningalerts.org.au",
    "localhost" => "localhost"
  }.each do |hostname, website|
    it "gives #{website} for #{hostname}" do
      expect(described_class.for(hostname)).to eq website
    end
  end
end
