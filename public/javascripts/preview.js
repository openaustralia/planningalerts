function preview(centre_lat, centre_lng, radius_in_metres) {
  map.removeAllPolylines();
  r = new mxn.Radius(new mxn.LatLonPoint(centre_lat, centre_lng), 10);
  p = r.getPolyline(radius_in_metres / 1000, "#FF0000");
  p.setWidth(0);
  p.setOpacity(0.2);
  map.addPolyline(p);
};
