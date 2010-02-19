class ApplicationsController < ApplicationController
  def index
    # TODO: Move the template over to using an xml builder
    @applications = Application.within(search_area).find(:all, :order => "date_scraped DESC", :limit => 100)
    render "shared/applications.rss", :layout => false, :content_type => Mime::XML
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
