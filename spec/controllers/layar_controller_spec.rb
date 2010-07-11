require 'spec_helper'

describe LayarController do
  it "should provide a rest api to serve the layar points of interest" do
    result = mock
    Application.should_receive(:paginate).with(:origin => [1.0, 2.0], :within => 3.0, :page => nil, :per_page => 10).and_return(result)

    get :getpoi, :lat => 1.0, :lon => 2.0, :radius => 3000
    assigns[:applications].should == result
  end
end
