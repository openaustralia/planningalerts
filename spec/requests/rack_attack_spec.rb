# frozen_string_literal: true

require "spec_helper"

# Rack::Attack is disabled in specs (see spec/spec_helper.rb), so call the
# throttle's own block to see which requests it counts.
describe "pages/ip throttle" do
  def counted_as(method, path)
    env = Rack::MockRequest.env_for(path, method:, "REMOTE_ADDR" => "192.0.2.1")
    Rack::Attack.throttles["pages/ip"].block.call(Rack::Attack::Request.new(env))
  end

  it "counts web pages by IP address" do
    expect(counted_as("GET", "/faq")).to eq "192.0.2.1"
  end

  %w[/cuttlefish/event /postal/event].each do |path|
    it "doesn't count mail server delivery updates to #{path}" do
      expect(counted_as("POST", path)).to be_nil
    end

    it "still counts other requests to #{path}" do
      expect(counted_as("GET", path)).to eq "192.0.2.1"
    end
  end
end
