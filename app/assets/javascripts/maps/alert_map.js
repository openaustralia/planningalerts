
//= require maps/basic_map_with_marker

function drawCircleOnMap(map, centre_lat, centre_lng, radius_in_metres) {
  return new google.maps.Circle({
    strokeColor: "#FF0000",
    strokeOpacity: 0.2,
    fillColor: "#FF0000",
    fillOpacity: 0.1,
    map: map,
    center: { lat: centre_lat, lng: centre_lng },
    radius: radius_in_metres,
  });
};

function initialiseAlertMap(map_div) {
  var lat = Number(map_div.dataset.lat);
  var lng = Number(map_div.dataset.lng);
  var radius_meters = Number(map_div.dataset.radiusMeters);

  var map = initialiseBasicMapWithMarker(map_div);
  return drawCircleOnMap(map, lat, lng, radius_meters);
}

