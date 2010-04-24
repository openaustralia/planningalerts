class ApplicationsController < ApplicationController
  def index
    @description = "Recent applications"
    @rss = applications_url(params.merge(:format => "rss"))
    if params[:authority_id]
      # TODO Handle the situation where the authority name isn't found
      authority = Authority.find_by_short_name_encoded(params[:authority_id])
      @applications = authority.applications.recent
      @description << " in #{authority.full_name}"
    elsif params[:postcode]
      # TODO: Check that it's a valid postcode (i.e. numerical and four digits)
      @applications = Application.recent.find_all_by_postcode(params[:postcode])
      @description << " in postcode #{params[:postcode]}"
    elsif params[:suburb]
      if params[:state]
        @applications = Application.recent.find_all_by_suburb_and_state(params[:suburb], params[:state])
        @description << " in #{params[:suburb]}, #{params[:state]}"
      else
        @applications = Application.recent.find_all_by_suburb(params[:suburb])
        @description << " in #{params[:suburb]}"
      end
    else
      if params[:area_size]
        if params[:address]
          location = Location.geocode(params[:address])
          location_text = params[:address]
        elsif params[:lat] && params[:lng]
          location = Location.new(params[:lat].to_f, params[:lng].to_f)
          location_text = location.to_s
        else
          raise "unexpected parameters"
        end
        @description << " within #{help.meters_in_words(params[:area_size].to_i)} of #{location_text}"
        # TODO: More concise form Application.recent(:origin => [location.lat, location.lng], :within => params[:area_size].to_f / 1000) doesn't work
        # http://www.binarylogic.com/2010/01/09/using-geokit-with-searchlogic/ might provide the answer
        @applications = Application.recent.find(:all, :origin => [location.lat, location.lng], :within => params[:area_size].to_f / 1000)
      elsif params[:bottom_left_lat] && params[:bottom_left_lng] && params[:top_right_lat] && params[:top_right_lng]
        lower_left = Location.new(params[:bottom_left_lat].to_f, params[:bottom_left_lng].to_f)
        upper_right = Location.new(params[:top_right_lat].to_f, params[:top_right_lng].to_f)
        search_area = Area.lower_left_and_upper_right(lower_left, upper_right)
        @description << " in the area (#{lower_left}) (#{upper_right})"
        @applications = Application.within(search_area).recent
      else
        @applications = Application.recent
      end
    end
    @page_title = @description
    respond_to do |format|
      format.html
      # TODO: Move the template over to using an xml builder
      format.rss { render "index.rss", :layout => false, :content_type => Mime::XML }
    end
  end
  
  def show
    @application = Application.find(params[:id])
    @page_title = @application.address
    
    # Find other applications nearby (within 10km area)
    @nearby_distance = 10000
    if @application.location
      @nearby_applications = Application.recent.find(:all, :origin => [@application.location.lat, @application.location.lng], :within => @nearby_distance / 1000.0)
      # Don't include the current application
      @nearby_applications.delete(@application)
    else
      @nearby_applications = []
    end
  end

  private
  
  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ApplicationHelper
  end
end
