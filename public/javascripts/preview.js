function preview(lower_left_lat, lower_left_lng, upper_right_lat, upper_right_lng) {
  map.removeAllPolylines();
    var myPoly = new Polyline([
    new LatLonPoint(lower_left_lat, lower_left_lng),
    new LatLonPoint(lower_left_lat, upper_right_lng),
    new LatLonPoint(upper_right_lat, upper_right_lng),
    new LatLonPoint(upper_right_lat, lower_left_lng),
    new LatLonPoint(lower_left_lat, lower_left_lng)
  ]);
  myPoly.setWidth(5);
  myPoly.setOpacity(0.7);
  myPoly.setColor("#EF2C2C");
  map.addPolyline(myPoly);
};
