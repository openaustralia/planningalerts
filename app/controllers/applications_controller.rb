class ApplicationsController < ApplicationController
  def index
    @description = "Recent applications"
    # Don't want the RSS feed to match the paging
    @rss = applications_url(params.merge(:format => "rss", :page => nil))
    if params[:authority_id]
      # TODO Handle the situation where the authority name isn't found
      authority = Authority.find_by_short_name_encoded(params[:authority_id])
      @applications = authority.applications.paginate :page => params[:page], :order => "date_scraped DESC"
      @description << " in #{authority.full_name_and_state}"
    elsif params[:postcode]
      # TODO: Check that it's a valid postcode (i.e. numerical and four digits)
      @applications = Application.paginate :conditions => {:postcode => params[:postcode]},
        :page => params[:page], :order => "date_scraped DESC"
      @description << " in postcode #{params[:postcode]}"
    elsif params[:suburb]
      if params[:state]
        @applications = Application.paginate :conditions => {:suburb => params[:suburb], :state => params[:state]},
          :page => params[:page], :order => "date_scraped DESC"
        @description << " in #{params[:suburb]}, #{params[:state]}"
      else
        @applications = Application.paginate :conditions => {:suburb => params[:suburb]},
          :page => params[:page], :order => "date_scraped DESC"
        @description << " in #{params[:suburb]}"
      end
    else
      radius = params[:radius] || params[:area_size]
      if radius
        if params[:address]
          location = Location.geocode(params[:address])
          location_text = params[:address]
        elsif params[:lat] && params[:lng]
          location = Location.new(params[:lat].to_f, params[:lng].to_f)
          location_text = location.to_s
        else
          raise "unexpected parameters"
        end
        @description << " within #{help.meters_in_words(radius.to_i)} of #{location_text}"
        # TODO: More concise form Application.recent(:origin => [location.lat, location.lng], :within => radius.to_f / 1000) doesn't work
        # http://www.binarylogic.com/2010/01/09/using-geokit-with-searchlogic/ might provide the answer
        @applications = Application.paginate :origin => [location.lat, location.lng], :within => radius.to_f / 1000,
          :page => params[:page], :order => "date_scraped DESC"
      elsif params[:bottom_left_lat] && params[:bottom_left_lng] && params[:top_right_lat] && params[:top_right_lng]
        lat0, lng0 = params[:bottom_left_lat].to_f, params[:bottom_left_lng].to_f
        lat1, lng1 = params[:top_right_lat].to_f, params[:top_right_lng].to_f
        @description << " in the area (#{lat0},#{lng0}) (#{lat1},#{lng1})"
        @applications = Application.paginate :bounds => [[lat0, lng0], [lat1, lng1]],
          :page => params[:page], :order => "date_scraped DESC"
      else
        @applications = Application.paginate :page => params[:page], :order => "date_scraped DESC"
      end
    end
    @page_title = @description
    respond_to do |format|
      format.html
      # TODO: Move the template over to using an xml builder
      format.rss { render "index.rss", :layout => false, :content_type => Mime::XML }
      format.js { render :json => @applications.to_json(:except => [:authority_id, :suburb, :state, :postcode, :distance]) }
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
