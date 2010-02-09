class ApiController < ApplicationController
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
    render :layout => false
  end
  
  def howto
    @page_title = "API"
    @menu_item = "api"
    
    example_address = "24 Bruce Road Glenbrook, NSW 2773"
    example_size = 4000
    example_authority = "Blue Mountains"
    # This lat/lng is for 24 Bruce Road as well
    example_lat = -33.772609
    example_lng = 150.624263
    # This covers most of Victoria and NSW
    example_bottom_left_lat = -38.556757
    example_bottom_left_lng = 140.833740
    example_top_right_lat = -29.113775
    example_top_right_lng = 153.325195

    @api_url = api_url
    # Doing this rather than using url_for so that the parameters stay in this order
    # TODO: Rejig the URL scheme for the API so we don't have to do above
    @api_example_address_url = "#{@api_url}?call=address&address=#{CGI.escape(example_address)}&area_size=#{example_size}"
    @api_example_latlong_url = "#{@api_url}?call=point&lat=#{example_lat}&lng=#{example_lng}&area_size=#{example_size}"
    @api_example_area_url = "#{@api_url}?call=area&bottom_left_lat=#{example_bottom_left_lat}&bottom_left_lng=#{example_bottom_left_lng}&top_right_lat=#{example_top_right_lat}&top_right_lng=#{example_top_right_lng}"
    @api_example_authority_url = "#{@api_url}?call=authority&authority=#{CGI.escape(example_authority)}"
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
