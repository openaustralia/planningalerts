require 'spec_helper'

describe User do
  it "should have no trouble creating a user with valid attributes" do
    User.create!(:email => "matthew@openaustralia.org", :address => "24 Bruce Road, Glenbrook, NSW", :area_size_meters => 200)
  end
  
  it "should automatically geocode the address" do
    loc = Location.new(1.0, 2.0)
    Location.should_receive(:geocode).with("24 Bruce Road, Glenbrook, NSW").and_return(loc)
    user = User.create!(:email => "matthew@openaustralia.org", :address => "24 Bruce Road, Glenbrook, NSW", :area_size_meters => 200)
    user.location.distance_to(loc).should < 1
  end
end
