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
  
  it "should have a valid email address" do
    u = User.new(:address => "24 Bruce Road, Glenbrook, NSW", :area_size_meters => 200)
    u.should_not be_valid
    u.errors.on(:email).should == "Please enter a valid email address"
    
    u = User.new(:email => "diddle@", :address => "24 Bruce Road, Glenbrook, NSW", :area_size_meters => 200)
    u.should_not be_valid
    u.errors.on(:email).should == "Please enter a valid email address"    
  end
end
