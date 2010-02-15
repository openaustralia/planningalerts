module ApiHowtoHelper
  # Turn a url for an arbitrary georss feed into a Google Map of that data
  def mapify(url, zoom = 13)
      "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=#{zoom}&om=1&q=#{CGI.escape(url)}"
  end
  
  def htmlify(url)
    url.gsub(/(\?|&)([a-z_]+)=/, '\1<strong>\2</strong>=')
  end
  
  def api_example_address_url(address = CGI.escape(Configuration::API_EXAMPLE_ADDRESS),
    area_size = Configuration::API_EXAMPLE_SIZE)
    # Doing this rather than using url_for so that the parameters stay in this order
    # TODO: Rejig the URL scheme for the API so we don't have to do above
    "#{api_url}?call=address&address=#{address}&area_size=#{area_size}"
  end
  
  def api_example_latlong_url(lat = Configuration::API_EXAMPLE_LAT, lng = Configuration::API_EXAMPLE_LNG, 
    area_size = Configuration::API_EXAMPLE_SIZE)
    "#{api_url}?call=point&lat=#{lat}&lng=#{lng}&area_size=#{area_size}"
  end
  
  def api_example_area_url(bottom_left_lat = Configuration::API_EXAMPLE_BOTTOM_LEFT_LAT,
    bottom_left_lng = Configuration::API_EXAMPLE_BOTTOM_LEFT_LNG,
    top_right_lat = Configuration::API_EXAMPLE_TOP_RIGHT_LAT,
    top_right_lng = Configuration::API_EXAMPLE_TOP_RIGHT_LNG)
    "#{api_url}?call=area&bottom_left_lat=#{bottom_left_lat}&bottom_left_lng=#{bottom_left_lng}&top_right_lat=#{top_right_lat}&top_right_lng=#{top_right_lng}"
  end
  
  def api_example_authority_url(authority = CGI.escape(Configuration::API_EXAMPLE_AUTHORITY))
    "#{api_url}?call=authority&authority=#{authority}"
  end
  
  def api_example_address_url_html
    htmlify(api_example_address_url("[address]", "[size_in_metres]"))
  end
  
  def api_example_latlong_url_html
    htmlify(api_example_latlong_url("[latitude]", "[longitude]", "[size_in_metres]"))
  end
  
  def api_example_area_url_html
    htmlify(api_example_area_url("[latitude]", "[longitude]", "[latitude]", "[longitude]"))
  end
  
  def api_example_authority_url_html
    htmlify(api_example_authority_url("[name]"))
  end
end
