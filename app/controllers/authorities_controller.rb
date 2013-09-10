class AuthoritiesController < ApplicationController
  caches_page :index
  
  def index
    # map from state name to authorities in that state
    states = Authority.active.find(:all, :group => "state", :order => "state").map{|a| a.state}
    @authorities = states.map do |state|
      [state, Authority.active.find_all_by_state(state, :order => "full_name")]
    end
  end

  def show
    @authority = Authority.find_by_short_name_encoded!(params[:id])
  end

  def test_feed
    # TODO: Error on duplicate council_reference
    # TODO: Error if first address can't be geocoded
    # TODO: Error if values set in feed but not making it through to the model (e.g. incorrect date syntax)
    # TODO: Warning on html in descriptions
    # TODO: Warning on lack of whitespace stripping
    @url = params[:url]
    if @url
      authority = Authority.new(:feed_url => @url)
      # The loaded applications
      @applications = authority.collect_unsaved_applications_date_range(Date.today, Date.today)
      # Try validating the applications and return all the errors for the first non-validating application
      @applications.each do |application|
        unless application.valid?
          @errored_application = application
          @applications = nil
          break
        end
      end
    end
  end

  def atdis_test_feed
    @url = params[:url]
    if @url
      puts "URL: #{@url}"
      if @url == "http://localhost:3000/atdis_test_feed/1/atdis/1.0/applications.json" || @url == "http://localhost:3000/atdis/1.0/applications.json?page=1"
        j = File.read(Rails.root.join("spec/atdis_json_examples/example1.json"))
        page = ATDIS::Page.read_json(j)
        page.url = @url
      elsif @url == "http://localhost:3000/atdis_test_feed/1/atdis/1.0/applications.json?page=2"
        j = File.read(Rails.root.join("spec/atdis_json_examples/example2.json"))
        page = ATDIS::Page.read_json(j)
        page.url = @url
      else
        page = ATDIS::Page.read_url(@url)
      end
      @page = page
    end
  end
end
