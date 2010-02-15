module ApiHowtoHelper
  # Turn a url for an arbitrary georss feed into a Google Map of that data
  def mapify(url, zoom = 13)
      "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=#{zoom}&om=1&q=#{CGI.escape(url)}"
  end
  
  def api_example_address_url
    # Doing this rather than using url_for so that the parameters stay in this order
    # TODO: Rejig the URL scheme for the API so we don't have to do above
    "#{api_url}?call=address&address=#{CGI.escape(Configuration::API_EXAMPLE_ADDRESS)}&area_size=#{Configuration::API_EXAMPLE_SIZE}"
  end
  
  def api_example_address_url_html
    "#{api_url}?<strong>call</strong>=address<br/>&<strong>address</strong>=[some address]&<strong>area_size</strong>=[size in metres]"
  end
  
  def api_example_latlong_url
    "#{api_url}?call=point&lat=#{Configuration::API_EXAMPLE_LAT}&lng=#{Configuration::API_EXAMPLE_LNG}&area_size=#{Configuration::API_EXAMPLE_SIZE}"
  end
  
  def api_example_latlong_url_html
    "#{api_url}?<strong>call</strong>=point<br/>&<strong>lat</strong>=[some latitude]&<strong>lng</strong>=[some longitude]&<strong>area_size</strong>=[size in metres]"
  end
  
  def api_example_area_url
    "#{api_url}?call=area&bottom_left_lat=#{Configuration::API_EXAMPLE_BOTTOM_LEFT_LAT}&bottom_left_lng=#{Configuration::API_EXAMPLE_BOTTOM_LEFT_LNG}&top_right_lat=#{Configuration::API_EXAMPLE_TOP_RIGHT_LAT}&top_right_lng=#{Configuration::API_EXAMPLE_TOP_RIGHT_LNG}"
  end
  
  def api_example_area_url_html
    "#{api_url}?<strong>call</strong>=area<br/>&<strong>bottom_left_lat</strong>=[some latitude]&<strong>bottom_left_lng</strong>=[some longitude]&<strong>top_right_lat</strong>=[some latitude]&<strong>top_right_lng</strong>=[some longitude]"
  end
  
  def api_example_authority_url
    "#{api_url}?call=authority&authority=#{CGI.escape(Configuration::API_EXAMPLE_AUTHORITY)}"
  end
  
  def api_example_authority_url_html
    "#{api_url}?<strong>call</strong>=authority<br/>&<strong>authority</strong>=[some name]"
  end
end
