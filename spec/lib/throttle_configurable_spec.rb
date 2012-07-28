require 'spec_helper'

# There's not really much point in testing the whole throttling stack because that's tested in the gem
# itself. Best just to concentrate on the bits that we're overriding

describe ThrottleConfigurable do
  let(:t) do
    ThrottleConfigurable.new(nil, :strategies => {
      "hourly" => {
        100 => "default",
        200 => ["1.2.3.7", "1.2.3.8"],
      },
      "daily" => {
        60000 => "1.2.3.4"
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
    t.max("1.2.3.4").should == 60000
    t.max("1.2.3.5").should be_nil
    t.max("1.2.3.7").should == 200
    t.max("1.2.3.8").should == 200
    t.max("1.2.3.9").should == 100
  end
end