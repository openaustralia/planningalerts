require 'spec_helper'

describe ApplicationsController do
  before :each do
    authority = mock_model(Authority, :full_name => "An authority", :short_name => "Blue Mountains")
    assigns[:application] = mock_model(Application, :map_url => "http://a.map.url",
      :description => "A planning application", :council_reference => "A1", :authority => authority, :info_url => "http://info.url", :comment_url => "http://comment.url",
      :on_notice_from => nil, :on_notice_to => nil)
    assigns[:nearby_applications] = []
  end
  
  describe "show" do
    before :each do
      assigns[:application].stub!(:address).and_return("foo")
      assigns[:application].stub!(:lat).and_return(1.0)
      assigns[:application].stub!(:lng).and_return(2.0)
      assigns[:application].stub!(:location).and_return(Location.new(1.0, 2.0))
    end
    
    it "should say when the application was received by the planning authority and when it appeared on PlanningAlerts" do
      assigns[:application].stub!(:date_received).and_return(20.days.ago)
      assigns[:application].stub!(:date_scraped).and_return(18.days.ago)
      render "applications/show"
      response.should have_tag("p.dates", "We found this application for you on the planning authority's website 18 days ago.\n    It was received by them 2 days earlier.")
    end
  
    it "should say something appropriate when the received date is not known" do
      assigns[:application].stub!(:date_received).and_return(nil)
      assigns[:application].stub!(:date_scraped).and_return(18.days.ago)
      render "applications/show"
      response.should have_tag("p.dates", "We found this application for you on the planning authority's website 18 days ago.\n    The date it was received by them was not recorded.")
    end
    
    it "should display the map" do
      assigns[:application].stub!(:date_received).and_return(nil)
      assigns[:application].stub!(:date_scraped).and_return(Time.now)
      render "applications/show"
      response.should have_tag("div#map_div")      
    end
    
    describe "on notice" do
      before :each do
        assigns[:application].stub!(:date_received).and_return(nil)
        assigns[:application].stub!(:date_scraped).and_return(Time.now)
      end
      
      it "should say when the application is on notice (and hasn't started yet)" do
        assigns[:application].stub!(:on_notice_from).and_return(2.days.from_now)
        assigns[:application].stub!(:on_notice_to).and_return(16.days.from_now)
        render "applications/show"
        response.should have_tag("p.on_notice", "The period for officially responding to this application starts in 2 days and finishes 14 days later.")
      end

      describe "period is in progress" do
        before :each do
          assigns[:application].stub!(:on_notice_from).and_return(2.days.ago)
          assigns[:application].stub!(:on_notice_to).and_return(12.days.from_now)
        end
        
        it "should say when the application is on notice" do
          render "applications/show"
          response.should have_tag("p.on_notice", "You have 12 days left to officially respond to this application.\n    The period for comment started 2 days ago.")
        end
      
        it "should only say when on notice to if there is no on notice from information" do
          assigns[:application].stub!(:on_notice_from).and_return(nil)
          render "applications/show"
          response.should have_tag("p.on_notice", "You have 12 days left to officially respond to this application.")      
        end
      end
      
      describe "period is finished" do
        before :each do
          assigns[:application].stub!(:on_notice_from).and_return(16.days.ago)
          assigns[:application].stub!(:on_notice_to).and_return(2.days.ago)
        end
        
        it "should say when the application is on notice" do
          render "applications/show"
          response.should have_tag("p.on_notice", "You're too late! The period for officially commenting on this application finished 2 days ago.\n    It lasted for 14 days.")
        end
      
        it "should only say when on notice to if there is no on notice from information" do
          assigns[:application].stub!(:on_notice_from).and_return(nil)
          render "applications/show"
          response.should have_tag("p.on_notice", "You're too late! The period for officially commenting on this application finished 2 days ago.")      
        end
      end
      
      it "should say nothing about notice period when there is no information" do
        assigns[:application].stub!(:on_notice_from).and_return(nil)
        assigns[:application].stub!(:on_notice_to).and_return(nil)
        render "applications/show"
        response.should_not have_tag("p.on_notice")
      end
    end
  end
  
  describe "show with application with no location" do
    it "should not display the map" do
      assigns[:application].stub!(:address).and_return("An address that can't be geocoded")
      assigns[:application].stub!(:lat).and_return(nil)
      assigns[:application].stub!(:lng).and_return(nil)
      assigns[:application].stub!(:location).and_return(nil)
      assigns[:application].stub!(:date_received).and_return(nil)
      assigns[:application].stub!(:date_scraped).and_return(Time.now)
        
      render "applications/show"
      response.should_not have_tag("div#map_div")
    end
  end
end