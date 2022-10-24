# frozen_string_literal: true

require "spec_helper"

describe "applications/show" do
  let(:authority) do
    mock_model(
      Authority,
      full_name: "An authority",
      short_name: "Blue Mountains",
      short_name_encoded: "blue_mountains"
    )
  end

  let(:application) do
    mock_model(
      Application,
      map_url: "http://a.map.url",
      description: "A planning application",
      council_reference: "A1",
      authority: authority,
      info_url: "http://info.url",
      on_notice_from: nil,
      on_notice_to: nil,
      find_all_nearest_or_recent: [],
      comments: []
    )
  end

  let(:alert) { Alert.new }

  let(:comment) do
    errors = instance_double(ActiveModel::Errors, :[] => nil)
    mock_model(Comment, errors: errors, text: nil, name: nil, email: nil)
  end

  before do
    assign(:comment, comment)
    assign(:alert, alert)
  end

  describe "show" do
    before do
      allow(application).to receive(:address).and_return("foo")
      allow(application).to receive(:lat).and_return(1.0)
      allow(application).to receive(:lng).and_return(2.0)
      allow(application).to receive(:location).and_return(Location.new(lat: 1.0, lng: 2.0))
    end

    it "displays the map" do
      allow(application).to receive(:date_received).and_return(nil)
      allow(application).to receive(:first_date_scraped).and_return(Time.zone.now)
      assign(:application, application)
      render
      expect(rendered).to have_selector("div#map_div")
    end

    it "says nothing about notice period when there is no information" do
      allow(application).to receive(:date_received).and_return(nil)
      allow(application).to receive(:first_date_scraped).and_return(Time.zone.now)
      allow(application).to receive(:on_notice_from).and_return(nil)
      allow(application).to receive(:on_notice_to).and_return(nil)
      assign(:application, application)
      render
      expect(rendered).not_to have_selector("p.on_notice")
    end
  end

  describe "show with application with no location" do
    it "does not display the map" do
      allow(application).to receive(:address).and_return("An address that can't be geocoded")
      allow(application).to receive(:lat).and_return(nil)
      allow(application).to receive(:lng).and_return(nil)
      allow(application).to receive(:location).and_return(nil)
      allow(application).to receive(:date_received).and_return(nil)
      allow(application).to receive(:first_date_scraped).and_return(Time.zone.now)
      assign(:application, application)

      render
      expect(rendered).not_to have_selector("div#map_div")
    end
  end
end
