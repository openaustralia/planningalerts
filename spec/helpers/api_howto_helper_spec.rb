# frozen_string_literal: true

require "spec_helper"

describe ApiHowtoHelper do
  it "should provide urls of examples of use of the api" do
    expect(helper.api_example_latlong_url("js", nil)).to eq("http://api.planningalerts.org.au/applications.js?lat=-33.772609&lng=150.624263&radius=4000")
    expect(helper.api_example_area_url("js", nil)).to eq("http://api.planningalerts.org.au/applications.js?bottom_left_lat=-38.556757&bottom_left_lng=140.83374&top_right_lat=-29.113775&top_right_lng=153.325195")
    expect(helper.api_example_authority_url("js", nil)).to eq("http://api.planningalerts.org.au/authorities/blue_mountains/applications.js")
    expect(helper.api_example_postcode_url("js", nil)).to eq("http://api.planningalerts.org.au/applications.js?postcode=2780")
    expect(helper.api_example_suburb_state_and_postcode_url("js", nil)).to eq("http://api.planningalerts.org.au/applications.js?postcode=2780&state=NSW&suburb=Katoomba")
  end

  it "should display the example urls nicely" do
    expect(helper.api_example_latlong_url_html("rss", nil)).to eq("http://api.planningalerts.org.au/applications.rss?<strong>key</strong>=[key]&amp;<strong>lat</strong>=[latitude]&amp;<strong>lng</strong>=[longitude]&amp;<strong>radius</strong>=[distance_in_metres]")
    expect(helper.api_example_area_url_html("rss", nil)).to eq("http://api.planningalerts.org.au/applications.rss?<strong>bottom_left_lat</strong>=[latitude]&amp;<strong>bottom_left_lng</strong>=[longitude]&amp;<strong>key</strong>=[key]&amp;<strong>top_right_lat</strong>=[latitude]&amp;<strong>top_right_lng</strong>=[longitude]")
    expect(helper.api_example_authority_url_html("rss", nil)).to eq("http://api.planningalerts.org.au/authorities/[name]/applications.rss?<strong>key</strong>=[key]")
    expect(helper.api_example_postcode_url_html("rss", nil)).to eq("http://api.planningalerts.org.au/applications.rss?<strong>key</strong>=[key]&amp;<strong>postcode</strong>=[postcode]")
    expect(helper.api_example_suburb_state_and_postcode_url_html("rss", nil)).to eq("http://api.planningalerts.org.au/applications.rss?<strong>key</strong>=[key]&amp;<strong>postcode</strong>=[postcode]&amp;<strong>state</strong>=[state]&amp;<strong>suburb</strong>=[suburb]")
  end

  it "should display the example urls nicely" do
    expect(helper.api_example_latlong_url_html("rss", "123")).to eq("http://api.planningalerts.org.au/applications.rss?<strong>key</strong>=123&amp;<strong>lat</strong>=[latitude]&amp;<strong>lng</strong>=[longitude]&amp;<strong>radius</strong>=[distance_in_metres]")
    expect(helper.api_example_area_url_html("rss", "123")).to eq("http://api.planningalerts.org.au/applications.rss?<strong>bottom_left_lat</strong>=[latitude]&amp;<strong>bottom_left_lng</strong>=[longitude]&amp;<strong>key</strong>=123&amp;<strong>top_right_lat</strong>=[latitude]&amp;<strong>top_right_lng</strong>=[longitude]")
    expect(helper.api_example_authority_url_html("rss", "123")).to eq("http://api.planningalerts.org.au/authorities/[name]/applications.rss?<strong>key</strong>=123")
    expect(helper.api_example_postcode_url_html("rss", "123")).to eq("http://api.planningalerts.org.au/applications.rss?<strong>key</strong>=123&amp;<strong>postcode</strong>=[postcode]")
    expect(helper.api_example_suburb_state_and_postcode_url_html("rss", "123")).to eq("http://api.planningalerts.org.au/applications.rss?<strong>key</strong>=123&amp;<strong>postcode</strong>=[postcode]&amp;<strong>state</strong>=[state]&amp;<strong>suburb</strong>=[suburb]")
  end
end
