require 'spec_helper'

describe "applications/show" do
  before :each do
    authority = mock_model(Authority, :full_name => "An authority", :short_name => "Blue Mountains", :contactable? => false)
    @application = mock_model(Application, :map_url => "http://a.map.url",
      :description => "A planning application", :council_reference => "A1", :authority => authority, :info_url => "http://info.url", :comment_url => "http://comment.url",
      :on_notice_from => nil, :on_notice_to => nil, :find_all_nearest_or_recent => [], :comments => [])
    errors = mock('Errors', :[] => nil)
    assigns[:comment] = mock_model(Comment, :errors => errors, :text => nil, :name => nil, :email => nil)
    Vanity.context = Struct.new(:vanity_identity).new('1')
    Vanity.playground.experiment(:signup_form_on_detail).chooses(false)
  end
  
  describe "show" do
    before :each do
      @application.stub!(:address).and_return("foo")
      @application.stub!(:lat).and_return(1.0)
      @application.stub!(:lng).and_return(2.0)
      @application.stub!(:location).and_return(Location.new(1.0, 2.0))
    end
    
    it "should display the map" do
      @application.stub!(:date_received).and_return(nil)
      @application.stub!(:date_scraped).and_return(Time.now)
      assigns[:application] = @application
      render
      rendered.should have_selector("div#map_div")      
    end
    
    it "should say nothing about notice period when there is no information" do
      @application.stub!(:date_received).and_return(nil)
      @application.stub!(:date_scraped).and_return(Time.now)
      @application.stub!(:on_notice_from).and_return(nil)
      @application.stub!(:on_notice_to).and_return(nil)
      assigns[:application] = @application
      render
      rendered.should_not have_selector("p.on_notice")
    end
  end
  
  describe "show with application with no location" do
    it "should not display the map" do
      @application.stub!(:address).and_return("An address that can't be geocoded")
      @application.stub!(:lat).and_return(nil)
      @application.stub!(:lng).and_return(nil)
      @application.stub!(:location).and_return(nil)
      @application.stub!(:date_received).and_return(nil)
      @application.stub!(:date_scraped).and_return(Time.now)
      assigns[:application] = @application
        
      render
      rendered.should_not have_selector("div#map_div")
    end
  end
end