require 'spec_helper'

describe Stat do
  it "should read in the number of applications that have gone out in emails" do
    Stat.delete_all
    Stat.create!(:key => "applications_sent", :value => 14)
    
    Stat.applications_sent.should == 14
  end

  it "should read in the number of emails that have been sent" do
    Stat.delete_all
    Stat.create!(:key => "emails_sent", :value => 2)
    
    Stat.emails_sent.should == 2
  end
  
  it "should return 0 when a key is missing and create the key" do
    Stat.delete_all
    #Stat.logger.should_receive(:error).with("Could not find key applications_sent for Stat lookup")
    Stat.applications_sent.should == 0
    Stat.find_by(key: "applications_sent").value.should == 0
  end
end
