require 'spec_helper'

describe LayarController do
  it "should provide a rest api to serve the layar points of interest" do
    result = [mock(:distance => 2, :lat => 1.0, :lng => 2.0, :id => 1, :address => " 1 Foo St\n Fooville")]
    Application.should_receive(:paginate).with(:origin => [1.0, 2.0], :within => 3.0, :page => "2", :per_page => 10).and_return(result)

    get :getpoi, :lat => 1.0, :lon => 2.0, :radius => 3000, :pageKey => "2"
    assigns[:applications].should == result
    expected_layar = {
      "id" => 1, "type" => 0,
      "lat" => 1.0, "lon" => 2.0, "distance" => 2000.0, 
      "actions" => [], "imageURL" => nil, "attribution" => nil,
      "title" => "1 Foo St Fooville", "line2" => nil, "line3" => nil, "line4" => nil,
    }
    JSON.parse(response.body).should == {"hotspots" => [expected_layar]}
  end
end
