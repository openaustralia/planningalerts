# frozen_string_literal: true

require "spec_helper"

describe "applications/show" do
  before :each do
    authority = mock_model(Authority, full_name: "An authority", short_name: "Blue Mountains", short_name_encoded: "blue_mountains", contactable?: false)
    @application = mock_model(
      Application,
      map_url: "http://a.map.url",
      description: "A planning application",
      council_reference: "A1",
      authority: authority,
      info_url: "http://info.url",
      comment_url: "http://comment.url",
      on_notice_from: nil,
      on_notice_to: nil,
      find_all_nearest_or_recent: [],
      comments: []
    )
    # Don't know how to double this when using formtastic
    @alert = Alert.new
    errors = double("Errors", :[] => nil)
    assign(:comment,
           mock_model(Comment, errors: errors, text: nil, name: nil, email: nil))
    Vanity.context = Struct.new(:vanity_identity).new("1")
  end

  describe "show" do
    before :each do
      allow(@application).to receive(:address).and_return("foo")
      allow(@application).to receive(:lat).and_return(1.0)
      allow(@application).to receive(:lng).and_return(2.0)
      allow(@application).to receive(:location).and_return(Location.new(lat: 1.0, lng: 2.0))
    end

    it "should display the map" do
      allow(@application).to receive(:date_received).and_return(nil)
      allow(@application).to receive(:date_scraped).and_return(Time.zone.now)
      assign(:application, @application)
      render
      expect(rendered).to have_selector("div#map_div")
    end

    it "should say nothing about notice period when there is no information" do
      allow(@application).to receive(:date_received).and_return(nil)
      allow(@application).to receive(:date_scraped).and_return(Time.zone.now)
      allow(@application).to receive(:on_notice_from).and_return(nil)
      allow(@application).to receive(:on_notice_to).and_return(nil)
      assign(:application, @application)
      render
      expect(rendered).not_to have_selector("p.on_notice")
    end
  end

  describe "show with application with no location" do
    it "should not display the map" do
      allow(@application).to receive(:address).and_return("An address that can't be geocoded")
      allow(@application).to receive(:lat).and_return(nil)
      allow(@application).to receive(:lng).and_return(nil)
      allow(@application).to receive(:location).and_return(nil)
      allow(@application).to receive(:date_received).and_return(nil)
      allow(@application).to receive(:date_scraped).and_return(Time.zone.now)
      assign(:application, @application)

      render
      expect(rendered).not_to have_selector("div#map_div")
    end
  end
end
