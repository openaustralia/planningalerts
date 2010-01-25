class ApiHowtoController < ApplicationController
  def index
    @page_title = "API"
    @menu_item = "api"
    
    @api_url = "http://dev.planningalerts.org.au/api.php"
    @api_example_address_url = "http://dev.planningalerts.org.au/api.php?call=address&address=24+Bruce+Road+Glenbrook%2C+NSW+2773&area_size=4000"
    @map_example_address_url = "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=14&om=1&q=http%3A%2F%2Fdev.planningalerts.org.au%2Fapi.php%3Fcall%3Daddress%26address%3D24%2BBruce%2BRoad%2BGlenbrook%252C%2BNSW%2B2773%26area_size%3D4000"
    @api_example_latlong_url = "http://dev.planningalerts.org.au/api.php?call=point&lat=-33.772609&lng=150.624263&area_size=4000"
    @map_example_latlong_url = "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=14&om=1&q=http%3A%2F%2Fdev.planningalerts.org.au%2Fapi.php%3Fcall%3Dpoint%26lat%3D-33.772609%26lng%3D150.624263%26area_size%3D4000"
    @api_example_area_url = "http://dev.planningalerts.org.au/api.php?call=area&bottom_left_lat=-38.556757&bottom_left_lng=140.83374&top_right_lat=-29.113775&top_right_lng=153.325195"
    @map_example_area_url = "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=6&om=1&q=http%3A%2F%2Fdev.planningalerts.org.au%2Fapi.php%3Fcall%3Darea%26bottom_left_lat%3D-38.556757%26bottom_left_lng%3D140.83374%26top_right_lat%3D-29.113775%26top_right_lng%3D153.325195"
    @api_example_authority_url = "http://dev.planningalerts.org.au/api.php?call=authority&authority=Blue+Mountains"
    @map_example_authority_url = "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=11&om=1&q=http%3A%2F%2Fdev.planningalerts.org.au%2Fapi.php%3Fcall%3Dauthority%26authority%3DBlue%2BMountains"
    
    @warnings = ""
    @onloadscript = ""
    @set_focus_control = ""
  end
end
