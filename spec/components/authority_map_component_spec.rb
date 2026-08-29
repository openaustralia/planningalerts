# frozen_string_literal: true

require "spec_helper"
require "rails_helper"

RSpec.describe AuthorityMapComponent, type: :component do
  before do
    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    ring = factory.linear_ring(
      [
        factory.point(150.0, -34.0),
        factory.point(151.0, -34.0),
        factory.point(151.0, -33.0),
        factory.point(150.0, -33.0),
        factory.point(150.0, -34.0)
      ]
    )
    boundary = factory.multi_polygon([factory.polygon(ring)])
    authority = build(:authority, full_name: "Byron Shire Council", short_name: "Byron", boundary:)
    render_inline(described_class.new(authority:))
  end

  it "initialises the map with the authority boundary" do
    expect(page).to have_css("div[x-init*='initialiseAuthorityMap']")
  end

  it "explains when the map can't be loaded" do
    expect(page).to have_text("We couldn't load the map")
  end

  it "includes a fallback link to the authority on Google Maps" do
    expect(page).to have_link("View this area on Google Maps", href: "https://www.google.com/maps/search/?api=1&query=Byron+Shire+Council")
  end

  it "keeps the fallback hidden unless the map fails to load" do
    expect(page).to have_css("[x-cloak][x-show='mapFailed']")
  end
end
