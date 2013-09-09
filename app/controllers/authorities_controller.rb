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
    @page = params[:page]
    if @page.blank?
      @page = 1
    else
      @page = @page.to_i
    end

    if @url
      if @url == "http://localhost:3000"
        file = case @page
        when 1
          "example1.json"
        when 2
          "example2.json"
        else
          raise
        end
        j = File.read(Rails.root.join("spec/atdis_json_examples/#{file}"))
        page = ATDIS::Page.read_json(j)
      else
        # Process feed using atdis gem
        feed = ATDIS::Feed.new(@url, @page)
        # Just grabs the first page of results
        page = feed.applications
      end
      @page = page
    end
  end
end
