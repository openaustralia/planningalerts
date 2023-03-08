function initialiseMap(elem, lat, lng, address, zoom) {
  var center = { lat: lat, lng: lng };
  var map = new google.maps.Map(
    elem,
    { zoom: zoom, center: center, fullscreenControl: false, streetViewControl: false, draggable: false, backgroundColor: "#d1e6d9" }
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
    fillColor: "#FF0000",
    fillOpacity: 0.1,
    map: map,
    center: { lat: centre_lat, lng: centre_lng },
    radius: radius_in_metres,
  });
};

window.addEventListener("DOMContentLoaded", function() {
  // Map on the application page
  var map_div = document.querySelector("#map_div.application");
  if (map_div) {
    initialiseMap(
      map_div,
      Number(map_div.dataset.lat),
      Number(map_div.dataset.lng),
      map_div.dataset.address,
      Number(map_div.dataset.zoom)
    );
  }

  // Streetview on the application page
  var pano = document.querySelector("#pano");
  if (pano) {
    initialisePano(
      pano,
      Number(pano.dataset.lat),
      Number(pano.dataset.lng),
      pano.dataset.address
    );
  }

  // Alert radius map on the edit alert page
  var map_alert_radius = document.querySelector("#map_div.alert-radius");
  if (map_alert_radius) {
    var lat = Number(map_alert_radius.dataset.lat);
    var lng = Number(map_alert_radius.dataset.lng);
    var address = map_alert_radius.dataset.address;
    var zoom = Number(map_alert_radius.dataset.zoom);
    var radius_meters = Number(map_alert_radius.dataset.radiusMeters);

    var map = initialiseMap(map_alert_radius, lat, lng, address, zoom);

    var circle = drawCircleOnMap(map, lat, lng, radius_meters);
    document.querySelector(".sizes").addEventListener("change", function(e) {
      circle.setRadius(parseInt(e.target.value));
    });
  }

  document.querySelectorAll(".map").forEach(function(e) {
    var lat = Number(e.dataset.lat);
    var lng = Number(e.dataset.lng);
    var address = e.dataset.address;
    var zoom = Number(e.dataset.zoom);
    var radius_meters = Number(e.dataset.radiusMeters);
    var map = initialiseMap(e, lat, lng, address, zoom);

    drawCircleOnMap(map, lat, lng, radius_meters);
  });

  this.document.querySelectorAll(".authority-map").forEach(function(e) {
    var map = new google.maps.Map(e,  { zoom: 4, center: { lat: -28, lng: 137 },
      fullscreenControl: false, streetViewControl: false, backgroundColor: "#d1e6d9" });

    var json = e.dataset.json;
    var min_lng = Number(e.dataset.minLng);
    var max_lng = Number(e.dataset.maxLng);
    var min_lat = Number(e.dataset.minLat);
    var max_lat = Number(e.dataset.maxLat);

    var sw = new google.maps.LatLng(min_lat, min_lng);
    var ne = new google.maps.LatLng(max_lat, max_lng);
    var bounds = new google.maps.LatLngBounds(sw, ne);

    map.fitBounds(bounds);
    map.data.loadGeoJson(json);
  });
});
