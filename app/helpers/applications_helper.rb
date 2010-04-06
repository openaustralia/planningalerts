module ApplicationsHelper
  def static_google_map_url(options = {:size => "512x512"})
    "http://maps.google.com/maps/api/staticmap?center=#{CGI.escape(options[:address])}&zoom=14&size=#{options[:size]}&maptype=roadmap&markers=color:blue|label:#{CGI.escape(options[:address])}|#{CGI.escape(options[:address])}&sensor=false"
  end
  
  def map(application)
    map = Mapstraction.new("map_div",:google)
    # Disable dragging of the map. Hmmm.. not quite sure if this is the most concise way of doing this
    map.record_init(map.dragging(false))
    map.center_zoom_init([application.lat, application.lng], 16)
    map.marker_init(Marker.new([application.lat, application.lng],:label => application.address))
    map
  end
end
