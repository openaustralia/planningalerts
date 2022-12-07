function initialiseMap(elem, lat, lng, address, zoom) {
  var center = { lat: lat, lng: lng };
  var map = new google.maps.Map(
    elem,
    { zoom: zoom, center: center, fullscreenControl: false, streetViewControl: false, draggable: false }
  );
  new google.maps.Marker({ position: center, map: map, title: address });

  return map;
}

function initialisePano(elem, latitude, longitude, address) {
  // Can't yet figure out how to make the POV point at the marker
  var pointToLookAt = new google.maps.LatLng(latitude, longitude);
  var myPano = new  google.maps.StreetViewPanorama(elem,
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
  return new google.maps.Circle({
    strokeColor: "#FF0000",
    strokeOpacity: 0.2,
    fillOpacity: 0,
    map: map,
    center: { lat: centre_lat, lng: centre_lng },
    radius: radius_in_metres,
  });
};

$(document).ready(function(){
  // Map on the application page
  if ($("#map_div.application").length) {
    var map_div = $("#map_div");
    initialiseMap(
      map_div[0],
      map_div.data("lat"),
      map_div.data("lng"),
      map_div.data("address"),
      map_div.data("zoom")
    );
  }
  // Streetview on the application page
  if ($("#pano").length) {
    initialisePano(
      $("#pano")[0],
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

    var map = initialiseMap(map_div[0], lat, lng, address, zoom);

    var circle = drawCircleOnMap(map, lat, lng, radius_meters);
    $('.sizes input').click(function(){
      circle.setRadius(parseInt($(this).val()));
    });  
  }

  $(".map").each(function(index) {
    var lat = $(this).data("lat");
    var lng = $(this).data("lng");
    var address = $(this).data("address");
    var zoom = $(this).data("zoom");
    var radius_meters = $(this).data("radius-meters");
    var map = initialiseMap(this, lat, lng, address, zoom);

    drawCircleOnMap(map, lat, lng, radius_meters);
  })
});
