require 'spec_helper'

describe Stat do
  fixtures :stats
  
  it "should read in the number of applications that have gone out in emails" do
    Stat.applications_sent.should == 15
    Stat.emails_sent.should == 3
  end
end
