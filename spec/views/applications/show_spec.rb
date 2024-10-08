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
      authority:,
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
    mock_model(Comment, errors:, text: nil, name: nil, email: nil)
  end

  before do
    assign(:comment, comment)
    assign(:alert, alert)
  end

  describe "show" do
    before do
      allow(application).to receive_messages(address: "foo", lat: 1.0, lng: 2.0, location: Location.new(lat: 1.0, lng: 2.0))
    end

    it "displays the map" do
      allow(application).to receive_messages(date_received: nil, first_date_scraped: Time.zone.now, comment_recipient_full_name: nil)
      assign(:application, application)
      assign(:comments, [])
      render
      # Really dumb way to check for the map
      expect(rendered).to have_css("div.bg-google-maps-green")
    end
  end

  describe "show with application with no location" do
    it "does not display the map" do
      allow(application).to receive_messages(address: "An address that can't be geocoded", lat: nil, lng: nil, location: nil, date_received: nil, first_date_scraped: Time.zone.now, comment_recipient_full_name: nil)
      assign(:application, application)
      assign(:comments, [])

      render
      expect(rendered).to have_no_selector("div.bg-google-maps-green")
    end
  end
end
