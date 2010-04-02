Ym4r::MapstractionPlugin::Marker.class_eval do
  #Creates a GMarker object from a georuby point. Accepts the same options as the GMarker constructor. Assumes the points of the line strings are stored in Longitude(x)/Latitude(y) order.
  def self.from_georuby(point,options = {})
    Marker.new([point.y,point.x],options)
  end
end

Ym4r::MapstractionPlugin::LatLonPoint.class_eval do
  #Creates a GLatLng object from a georuby point. Assumes the points of the line strings are stored in Longitude(x)/Latitude(y) order.
  def self.from_georuby(point)
    LatLonPoint.new([point.y,point.x])
  end
end

