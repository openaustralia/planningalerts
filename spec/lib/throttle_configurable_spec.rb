require 'spec_helper'

# There's not really much point in testing the whole throttling stack because that's tested in the gem
# itself. Best just to concentrate on the bits that we're overriding

describe ThrottleConfigurable do
  let(:t) do
    ThrottleConfigurable.new(nil, :strategies => {
      "hourly" => {
        100 => "default",
        3 => ["1.2.3.7", "1.2.3.8"],
      },
      "daily" => {
        2 => "1.2.3.4"
      },
      "unlimited" => "1.2.3.5",
      "blocked" => "1.2.3.6",
    })
  end

  it "should be able to extract the strategy setting for a particular ip address" do
    t.strategy("1.2.3.4").should == "daily"
    t.strategy("1.2.3.5").should == "unlimited"
    t.strategy("1.2.3.6").should == "blocked"
    t.strategy("1.2.3.7").should == "hourly"
    t.strategy("1.2.3.8").should == "hourly"
    t.strategy("1.2.3.9").should == "hourly"
  end

  it "should be able to extract the maximum hits for a particular ip address" do
    t.max("1.2.3.4").should == 2
    t.max("1.2.3.5").should be_nil
    t.max("1.2.3.7").should == 3
    t.max("1.2.3.8").should == 3
    t.max("1.2.3.9").should == 100
  end

  it "should check that the strategy names are valid" do
    lambda {ThrottleConfigurable.new(nil,
      :strategies => {"foo" => "1.2.3.4"}
      )}.should raise_error "Invalid strategy name used: foo"
  end

  it "should check that the max count is valid" do
    lambda {ThrottleConfigurable.new(nil,
      :strategies => {"hourly" => {"foo" => "1.2.3.4"}}
      )}.should raise_error "Invalid max count used: foo"
  end

  it "should check that the ip addresses are potentially sane" do
    lambda {ThrottleConfigurable.new(nil,
      :strategies => {"hourly" => {100 => "257.2.3.4"}}
      )}.should raise_error "Invalid ip address used: 257.2.3.4"
  end

  it "should check that there is a default setting" do
    lambda {ThrottleConfigurable.new(nil,
      :strategies => {"hourly" => {100 => "1.2.3.4"}}
      )}.should raise_error "No default setting"
  end

  it "should not do any throttling with the unlimited strategy" do
    request = mock(:request, :ip => "1.2.3.5")
    t.allowed?(request).should be_true
  end

  it "should never allow the request when an ip is blocked" do
    request = mock(:request, :ip => "1.2.3.6")
    t.allowed?(request).should be_false
  end

  it "should limit request to the max count in the hourly strategy" do
    request = mock(:request, :ip => "1.2.3.7")
    t.allowed?(request).should be_true
    t.allowed?(request).should be_true
    t.allowed?(request).should be_true
    t.allowed?(request).should be_false
  end

  it "should limit requests to the max count in the daily strategy too" do
    request = mock(:request, :ip => "1.2.3.4")
    t.allowed?(request).should be_true
    t.allowed?(request).should be_true
    t.allowed?(request).should be_false
  end
end