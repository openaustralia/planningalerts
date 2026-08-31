# frozen_string_literal: true

require "spec_helper"
require "rails_helper"

RSpec.describe StreetviewComponent, type: :component do
  before do
    render_inline(described_class.new(lat: -33.916812, lng: 151.027302, address: "24 Bruce Road Glenbrook, NSW 2773"))
  end

  it "explains when the streetview can't be loaded" do
    expect(page).to have_text("We couldn't load the streetview")
  end

  it "includes a fallback link to the streetview on Google Maps" do
    expect(page).to have_link("View the streetview on Google Maps", href: "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=-33.916812%2C151.027302")
  end

  it "keeps the fallback hidden unless the streetview fails to load" do
    expect(page).to have_css("[x-cloak][x-show='mapFailed']")
  end

  # See the equivalent example in map_component_spec.rb, and #2193.
  it "reaches the fallback when the streetview javascript is missing altogether" do
    x_init = page.find("[x-data]")["x-init"]

    expect(x_init).to start_with("runWithFallback(() => initialisePano(")
    expect(x_init).to end_with(", () => mapFailed = true)")
  end
end
