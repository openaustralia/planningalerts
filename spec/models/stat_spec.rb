require 'spec_helper'

describe Stat do
  it "should read in the number of applications that have gone out in emails" do
    Stat.should_receive(:find).with(:first, :conditions => {:key => "applications_sent"}).and_return(mock(:value => 14))
    
    Stat.applications_sent.should == 14
  end

  it "should read in the number of emails that have been sent" do
    Stat.should_receive(:find).with(:first, :conditions => {:key => "emails_sent"}).and_return(mock(:value => 2))
    
    Stat.emails_sent.should == 2
  end
  
  it "should return 0 when a key is missing but log an error" do
    Stat.logger.should_receive(:error).with("Could not find key applications_sent for Stat lookup")
    Stat.should_receive(:find).with(:first, :conditions => {:key => "applications_sent"}).and_return(nil)
    Stat.applications_sent.should == 0
  end
end
