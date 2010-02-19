module ApiHowtoHelper
  # Turn a url for an arbitrary georss feed into a Google Map of that data
  def mapify(url, zoom = 13)
      "http://maps.google.com/maps?f=q&hl=en&layer=&ie=UTF8&z=#{zoom}&om=1&q=#{CGI.escape(url)}"
  end
  
  def htmlify(url)
    url.gsub(/(\?|&|&amp;)([a-z_]+)=/, '\1<strong>\2</strong>=')
  end
  
  def api_example_address_url(address = Configuration::API_EXAMPLE_ADDRESS,
    area_size = Configuration::API_EXAMPLE_SIZE)
    applications_url(:format => "rss", :address => address, :area_size => area_size)
  end
  
  def api_example_latlong_url(lat = Configuration::API_EXAMPLE_LAT, lng = Configuration::API_EXAMPLE_LNG, 
    area_size = Configuration::API_EXAMPLE_SIZE)
    applications_url(:format => "rss", :lat => lat, :lng => lng, :area_size => area_size)
  end
  
  def api_example_area_url(bottom_left_lat = Configuration::API_EXAMPLE_BOTTOM_LEFT_LAT,
    bottom_left_lng = Configuration::API_EXAMPLE_BOTTOM_LEFT_LNG,
    top_right_lat = Configuration::API_EXAMPLE_TOP_RIGHT_LAT,
    top_right_lng = Configuration::API_EXAMPLE_TOP_RIGHT_LNG)
    applications_url(:format => "rss",
      :bottom_left_lat => bottom_left_lat, :bottom_left_lng => bottom_left_lng,
      :top_right_lat => top_right_lat, :top_right_lng => top_right_lng)
  end
  
  def api_example_authority_url(authority = CGI.escape(Configuration::API_EXAMPLE_AUTHORITY))
    "#{api_url}?call=authority&authority=#{authority}"
  end
  
  def api_example_address_url_html
    # Doing this hackery with 11's and 22's so that we don't escape "[" and "]"
    htmlify(api_example_address_url("11", "22").sub("11", "[address]").sub("22", "[size_in_metres]"))
  end
  
  def api_example_latlong_url_html
    htmlify(api_example_latlong_url("11", "22", "33").sub("11", "[latitude]").sub("22", "[longitude]").sub("33", "[size_in_metres]"))
  end
  
  def api_example_area_url_html
    htmlify(api_example_area_url("11", "22", "11", "22").gsub("11", "[latitude]").gsub("22", "[longitude]"))
  end
  
  def api_example_authority_url_html
    htmlify(api_example_authority_url("[name]"))
  end
end
