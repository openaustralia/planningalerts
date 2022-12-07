//= require mxn.js
//= require mxn.core.js
//= require mxn.googlev3.core.js

function initialiseMap(id, lat, lng, address, zoom) {
  var map = new mxn.Mapstraction(id, "googlev3");
  var centre = new mxn.LatLonPoint(lat, lng);
  map.setCenterAndZoom(centre, zoom);
  map.addSmallControls();
  map.addMapTypeControls();
  map.dragging(false);
  var marker = new mxn.Marker(centre)
  marker.setLabel(address);
  map.addMarker(marker);

  return map;
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

function drawCircleOnMap(map, centre_lat, centre_lng, radius_in_metres) {
  map.removeAllPolylines();
  var r = new mxn.Radius(new mxn.LatLonPoint(centre_lat, centre_lng), 10);
  var p = r.getPolyline(radius_in_metres / 1000, "#FF0000");
  p.setWidth(0);
  p.setOpacity(0.2);
  map.addPolyline(p);
};

$(document).ready(function(){
  // Map on the application page
  if ($("#map_div.application").length) {
    var map_div = $("#map_div");
    initialiseMap(
      "map_div",
      map_div.data("lat"),
      map_div.data("lng"),
      map_div.data("address"),
      map_div.data("zoom")
    );
  }
  // Streetview on the application page
  if ($("#pano").length) {
    initialisePano(
      "pano",
      $("#pano").data("lat"),
      $("#pano").data("lng"),
      $("#pano").data("address")
    );
  }
  // Alert radius map on the edit alert page
  if ($("#map_div.alert-radius").length) {
    var map_div = $("#map_div");
    var lat = map_div.data("lat");
    var lng = map_div.data("lng");
    var address = map_div.data("address");
    var zoom = map_div.data("zoom")
    var radius_meters = map_div.data("radius-meters");

    var map = initialiseMap("map_div", lat, lng, address, zoom);

    drawCircleOnMap(map, lat, lng, radius_meters);
    $('.sizes input').click(function(){
      drawCircleOnMap(map, lat, lng, $(this).val());
    });  
  }
});
