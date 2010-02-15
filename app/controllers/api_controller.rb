class ApiController < ApplicationController
  #caches_page :howto

  def index
    # TODO: Move the template over to using an xml builder
    if params[:call] == "address" || params[:call] == "point" || params[:call] == "area"
      @applications = Application.within(search_area).find(:all, :order => "date_scraped DESC", :limit => 100)
    elsif params[:call] == "authority"
      # TODO Handle the situation where the authority name isn't found
      authority = Authority.find_by_short_name(params[:authority])
      @applications = authority.applications(:order => "date_scraped DESC", :limit => 100)
    else
      raise "unexpected value for :call"
    end
    @base_url = root_url
    render :layout => false, :content_type => Mime::XML
  end
  
  def howto
    @page_title = "API"
  end
  
  private
  
  def search_area
    case params[:call]
    when "address", "point"
      location = params[:call] == "address" ?
        Location.geocode(params[:address]) : Location.new(params[:lat].to_f, params[:lng].to_f)
      Area.centre_and_size(location, params[:area_size].to_i)
    when "area"
      lower_left = Location.new(params[:bottom_left_lat].to_f, params[:bottom_left_lng].to_f)
      upper_right = Location.new(params[:top_right_lat].to_f, params[:top_right_lng].to_f)
      Area.lower_left_and_upper_right(lower_left, upper_right)
    else
      raise "unexpected value for :call"
    end
  end
end
