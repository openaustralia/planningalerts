# frozen_string_literal: true

require "spec_helper"
require "rails_helper"

RSpec.describe MapWithRadiusComponent, type: :component do
  before do
    render_inline(described_class.new(lat: -33.916812, lng: 151.027302, address: "24 Bruce Road Glenbrook, NSW 2773", radius_meters: "radius_meters", zoom: 12))
  end

  it "explains when the map can't be loaded" do
    expect(page).to have_text("We couldn't load the map")
  end

  it "includes a fallback link to the location on Google Maps" do
    expect(page).to have_link("View this location on Google Maps", href: "https://www.google.com/maps/search/?api=1&query=-33.916812%2C151.027302")
  end

  it "keeps the fallback hidden unless the map fails to load" do
    expect(page).to have_css("[x-cloak][x-show='mapFailed']")
  end

  it "only updates the circle radius when the map has loaded" do
    expect(page).to have_css("div[x-init*='circle && circle.setRadius(value)']")
  end

  # See the equivalent example in map_component_spec.rb, and #2193. Here the
  # fallback also has to leave circle falsy, so the radius watcher above stays
  # safe when there is no map to draw a circle on.
  it "reaches the fallback when the map javascript is missing altogether" do
    x_init = page.find("[x-data]")["x-init"]

    expect(x_init).to start_with("circle = await runWithFallback(() => initialiseAlertMap(")
    expect(x_init).to include("), () => { mapFailed = true; return null });")
  end
end
