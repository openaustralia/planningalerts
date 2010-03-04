class ApplicationsController < ApplicationController
  def index
    if params[:authority_id]
      # TODO Handle the situation where the authority name isn't found
      authority = Authority.find_by_short_name(params[:authority_id])
      @applications = authority.applications(:order => "date_scraped DESC", :limit => 100)
    else
      # TODO: Move the template over to using an xml builder
      @applications = Application.within(search_area).find(:all, :order => "date_scraped DESC", :limit => 100)
    end
    render "shared/applications.rss", :layout => false, :content_type => Mime::XML
  end
  
  def show
    @application = Application.find(params[:id])
    @page_title = @application.address
    
    # TODO: Since this is really to do with presentation this should be in a helper
    @map = Mapstraction.new("map_div",:google)
    @map.control_init(:small => true)
    @map.center_zoom_init([@application.lat, @application.lng], 14)
    @map.marker_init(Marker.new([@application.lat, @application.lng],:label => @application.address,
      :info_bubble => "<b>#{@application.address}</b><p>#{@application.description}</p>"))
    
    # TODO: Display date received and date scraped
    
    # Find other applications nearby (within 10km area)
    @nearby_distance = 10000
    search_area = Area.centre_and_size(@application.location, @nearby_distance)
    @nearby_applications = Application.within(search_area).find(:all, :order => "date_scraped DESC", :limit => 10)
    # Don't include the current application
    @nearby_applications.delete(@application)
  end

  private
  
  def search_area
    if params[:area_size]
      if params[:address]
        location = Location.geocode(params[:address])
      elsif params[:lat] && params[:lng]
        location = Location.new(params[:lat].to_f, params[:lng].to_f)
      else
        raise "unexpected parameters"
      end
      Area.centre_and_size(location, params[:area_size].to_i)
    elsif params[:bottom_left_lat] && params[:bottom_left_lng] && params[:top_right_lat] && params[:top_right_lng]
      lower_left = Location.new(params[:bottom_left_lat].to_f, params[:bottom_left_lng].to_f)
      upper_right = Location.new(params[:top_right_lat].to_f, params[:top_right_lng].to_f)
      Area.lower_left_and_upper_right(lower_left, upper_right)
    else
      raise "unexpected parameters"
    end
  end
end
