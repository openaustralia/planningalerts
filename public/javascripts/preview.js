function preview(lower_left_lat, lower_left_lng, upper_right_lat, upper_right_lng) {
  map.removeAllPolylines();
    var myPoly = new mxn.Polyline([
    new mxn.LatLonPoint(lower_left_lat, lower_left_lng),
    new mxn.LatLonPoint(lower_left_lat, upper_right_lng),
    new mxn.LatLonPoint(upper_right_lat, upper_right_lng),
    new mxn.LatLonPoint(upper_right_lat, lower_left_lng)
  ]);
  myPoly.setWidth(0);
  myPoly.setOpacity(0.2);
  myPoly.setClosed(true);
  map.addPolyline(myPoly);
};
