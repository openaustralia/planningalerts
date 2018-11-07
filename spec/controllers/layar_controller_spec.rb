# frozen_string_literal: true

require "spec_helper"

describe LayarController do
  it "should provide a rest api to serve the layar points of interest" do
    application = double(distance: 2, lat: 1.0, lng: 2.0, id: 101, address: " 1 Foo St\n Fooville",
                         description: "1234 678901234 67890123 56789 12345 1234567 90123456789 123456 89\n1234567890 2345678 012345678 01234512345")
    result = [application]
    allow(result).to receive(:current_page).and_return(1)
    allow(result).to receive(:total_pages).and_return(2)
    allow(Application).to receive_message_chain(:near, :paginate).and_return(result)
    get :getpoi, lat: 1.0, lon: 2.0, radius: 3000, pageKey: "2"
    expect(assigns[:applications]).to eq(result)
    expected_layar = {
      "id" => 101, "type" => 1,
      "lat" => 1000000, "lon" => 2000000, "distance" => 2000.0, "imageURL" => "http://www.planningalerts.org.au/images/layar/icon_100x75.png", "attribution" => nil,
      "title" => "1 Foo St Fooville",
      "line2" => "1234 678901234 67890123 56789 12345",
      "line3" => "1234567 90123456789 123456 89",
      "line4" => "1234567890 2345678 012345678 012...",
      "actions" => [
        {
          "label" => "More info",
          "uri" => "http://test.host/applications/101?utm_medium=ar&utm_source=layar"
        }
      ]
    }
    expect(JSON.parse(response.body)).to eq(
      "hotspots" => [expected_layar], "nextPageKey" => 2, "morePages" => true,
      "layer" => "planningalertsaustralia", "errorCode" => 0, "errorString" => nil, "radius" => 3000
    )
  end
end
