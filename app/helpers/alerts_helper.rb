module AlertsHelper
  def preview_map(area)
    map = Mapstraction.new("map_div",:google)
    map.control_init(:small => true)
    map.center_zoom_init([area.centre.lat, area.centre.lng], 13)
    map.polyline_init(
      Polyline.new([
        LatLonPoint.new([area.lower_left.lat, area.lower_left.lng]),
        LatLonPoint.new([area.lower_left.lat, area.upper_right.lng]),
        LatLonPoint.new([area.upper_right.lat, area.upper_right.lng]),
        LatLonPoint.new([area.upper_right.lat, area.lower_left.lng]),
        LatLonPoint.new([area.lower_left.lat, area.lower_left.lng]),
      ], :width => 5, :color => "#EF2C2C", :opacity => 0.7))
    map
  end
end
