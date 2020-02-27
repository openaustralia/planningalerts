# frozen_string_literal: true

require "spec_helper"

describe "api routing" do
  it do
    expect(get: "authorities/foo/applications.js")
      .to route_to(controller: "api", action: "authority", authority_id: "foo", format: "js")
  end

  it do
    expect(get: "applications.js?postcode=2780")
      .to route_to(controller: "api", action: "suburb_postcode", format: "js", postcode: "2780")
  end

  it do
    expect(get: "applications.js?suburb=Katoomba")
      .to route_to(controller: "api", action: "suburb_postcode", format: "js", suburb: "Katoomba")
  end

  it do
    expect(get: "applications.js?address=Foobar+Street")
      .to route_to(controller: "api", action: "point", format: "js", address: "Foobar Street")
  end

  it do
    expect(get: "applications.js?lat=1&lng=2")
      .to route_to(controller: "api", action: "point", format: "js", lat: "1", lng: "2")
  end

  it do
    expect(get: "applications.js?bottom_left_lat=1&bottom_left_lng=2&top_right_lat=3&top_right_lng=4")
      .to route_to(controller: "api", action: "area", format: "js", bottom_left_lat: "1", bottom_left_lng: "2", top_right_lat: "3", top_right_lng: "4")
  end

  it do
    expect(get: "applications.js")
      .to route_to(controller: "api", action: "all", format: "js")
  end
end

describe "routing to normal html pages which are similar to api routes" do
  it do
    expect(get: "authorities/foo/applications")
      .to route_to(controller: "applications", action: "index", authority_id: "foo")
  end

  it do
    expect(get: "applications")
      .to route_to(controller: "applications", action: "index")
  end
end
