//= require mxn.js
//= require mxn.core.js
//= require mxn.googlev3.core.js

function initialiseMapAndPano(latitude, longitude, address) {
  initialiseMap("map_div", latitude, longitude, address);
  initialisePano("pano", latitude, longitude, address);
}

function initialiseMap(id, latitude, longitude, address) {
  var map = new mxn.Mapstraction(id, "googlev3");
  point = new mxn.LatLonPoint(latitude, longitude);
  map.setCenterAndZoom(point,16);
  map.addControls({ zoom: 'small', map_type: true });
  map.dragging(false);
  marker = new mxn.Marker(point)
  marker.setLabel(address);
  map.addMarker(marker);
}

function initialisePano(id, latitude, longitude, address) {
  // Can't yet figure out how to make the POV point at the marker
  var pointToLookAt = new google.maps.LatLng(latitude, longitude);
  var myPano = new  google.maps.StreetViewPanorama(document.getElementById(id),
    {position: pointToLookAt, navigationControl: false, addressControl: false, zoom: 0});
  google.maps.event.addListener(myPano, 'position_changed', function() {
    // Orient the camera to face the position we're interested in
    var angle = computeAngle(pointToLookAt, myPano.getPosition());
    myPano.setPov({heading:angle, pitch:0, zoom:1});
  });
  var panoMarker = new google.maps.Marker({position: pointToLookAt, title: address});
  panoMarker.setMap(myPano);
}

function computeAngle(endLatLng, startLatLng) {
  var DEGREE_PER_RADIAN = 57.2957795;
  var RADIAN_PER_DEGREE = 0.017453;

  var dlat = endLatLng.lat() - startLatLng.lat();
  var dlng = endLatLng.lng() - startLatLng.lng();
  // We multiply dlng with cos(endLat), since the two points are very closeby,
  // so we assume their cos values are approximately equal.
  var yaw = Math.atan2(dlng * Math.cos(endLatLng.lat() * RADIAN_PER_DEGREE), dlat)
    * DEGREE_PER_RADIAN;
  return wrapAngle(yaw);
}

function wrapAngle(angle) {
  if (angle >= 360) {
    angle -= 360;
  } else if (angle < 0) {
    angle += 360;
  }
  return angle;
}

function preview(centre_lat, centre_lng, radius_in_metres) {
  map.removeAllPolylines();
  r = new mxn.Radius(new mxn.LatLonPoint(centre_lat, centre_lng), 10);
  p = r.getPolyline(radius_in_metres / 1000, "#FF0000");
  p.setWidth(0);
  p.setOpacity(0.2);
  map.addPolyline(p);
};
