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
    
    @api_url = api_url
    # Doing this rather than using url_for so that the parameters stay in this order
    # TODO: Rejig the URL scheme for the API so we don't have to do above
    @api_example_address_url = "#{@api_url}?call=address&address=#{CGI.escape(Configuration::API_EXAMPLE_ADDRESS)}&area_size=#{Configuration::API_EXAMPLE_SIZE}"
    @api_example_latlong_url = "#{@api_url}?call=point&lat=#{Configuration::API_EXAMPLE_LAT}&lng=#{Configuration::API_EXAMPLE_LNG}&area_size=#{Configuration::API_EXAMPLE_SIZE}"
    @api_example_area_url = "#{@api_url}?call=area&bottom_left_lat=#{Configuration::API_EXAMPLE_BOTTOM_LEFT_LAT}&bottom_left_lng=#{Configuration::API_EXAMPLE_BOTTOM_LEFT_LNG}&top_right_lat=#{Configuration::API_EXAMPLE_TOP_RIGHT_LAT}&top_right_lng=#{Configuration::API_EXAMPLE_TOP_RIGHT_LNG}"
    @api_example_authority_url = "#{@api_url}?call=authority&authority=#{CGI.escape(Configuration::API_EXAMPLE_AUTHORITY)}"
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
