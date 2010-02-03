class ApiController < ApplicationController
  def index
    # TODO: Move the template over to using an xml builder
    @applications = Application.find(:all)
    @base_url = url_for(:controller => :signup)
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

    @api_url = url_for(:controller => :api)
    # Doing this rather than using url_for so that the parameters stay in this order
    # TODO: Rejig the URL scheme for the API so we don't have to do above
    @api_example_address_url = "#{@api_url}?call=address&address=#{CGI.escape(example_address)}&area_size=#{example_size}"
    @api_example_latlong_url = "#{@api_url}?call=point&lat=#{example_lat}&lng=#{example_lng}&area_size=#{example_size}"
    @api_example_area_url = "#{@api_url}?call=area&bottom_left_lat=#{example_bottom_left_lat}&bottom_left_lng=#{example_bottom_left_lng}&top_right_lat=#{example_top_right_lat}&top_right_lng=#{example_top_right_lng}"
    @api_example_authority_url = "#{@api_url}?call=authority&authority=#{CGI.escape(example_authority)}"

    @warnings = ""
    @onloadscript = ""
    @set_focus_control = ""
  end
end
