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
  end

  # Available at http://localhost:3000/atdis/1.0/applications.json
  def atdis_test_data
    # Make some test 
    render :json => {
      :response => [
        {
          :application => {
            :info => {
              :dat_id => "DA2013-0381",
              :description => "New pool plus deck",
              :authority => "Example Council Shire Council",
              :lodgement_date => "2013-04-20T02:01:07Z",
              :determination_date => "2013-06-20T02:01:07Z",
              :notification_start_date => "2013-04-20T02:01:07Z",
              :notification_end_date => "2013-05-20T02:01:07Z",
              :status => "OPEN"
            },
            :reference => {
              :more_info_url => "http://www.examplecouncil.nsw.gov.au/atdis/1.0/applications/DA2013-0381"
            },
            :location => {
              :address => "123 Fourfivesix Street Neutral Bay NSW 2089",
              :land_title_ref => {
                :lot => "10",
                :section => "ABC",
                :dpsp_id => "DP2013-0381"
              }
            }
          }
        },
        {
          :application => {}
        }
      ],
      :count => 2,
      :pagination => {
        :previous => nil,
        :next => nil,
        :current => 1,
        :per_page => 25,
        :count => 100,
        :pages => 1
      }
    }
  end
end
