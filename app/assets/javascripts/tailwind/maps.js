//= require maps/pano_utils

async function initialisePano2(elem) {
  const { StreetViewPanorama } = await google.maps.importLibrary("streetView");
  const { Marker } = await google.maps.importLibrary("marker")

  var lat = Number(elem.dataset.lat);
  var lng = Number(elem.dataset.lng);
  var address = elem.dataset.address;

  // Can't yet figure out how to make the POV point at the marker
  var pointToLookAt = new google.maps.LatLng(lat, lng);
  var myPano = new StreetViewPanorama(elem,
    {position: pointToLookAt, navigationControl: false, addressControl: false, zoom: 0, scrollwheel: false, fullscreenControl: false, linksControl: false});
  google.maps.event.addListener(myPano, 'position_changed', function() {
    // Orient the camera to face the position we're interested in
    var angle = computeAngle(pointToLookAt, myPano.getPosition());
    myPano.setPov({heading:angle, pitch:0, zoom:1});
  });
  var panoMarker = new Marker({position: pointToLookAt, title: address});
  panoMarker.setMap(myPano);
}

async function initialiseBasicMapWithMarker2(map_div) {
  const { Map } = await google.maps.importLibrary("maps");
  const { Marker } = await google.maps.importLibrary("marker");

  var center = { lat: Number(map_div.dataset.lat), lng: Number(map_div.dataset.lng) };
  var address = map_div.dataset.address;
  var zoom = Number(map_div.dataset.zoom);

  var map = new Map(
    map_div,
    { zoom: zoom, center: center, fullscreenControl: false, streetViewControl: false, draggable: false, backgroundColor: "#d1e6d9" }
  );
  new Marker({ position: center, map: map, title: address });

  return map;
}

async function initialiseAlertMap2(map_div) {
  var lat = Number(map_div.dataset.lat);
  var lng = Number(map_div.dataset.lng);
  var radius_meters = Number(map_div.dataset.radiusMeters);

  var map = await initialiseBasicMapWithMarker2(map_div);
  return drawCircleOnMap2(map, lat, lng, radius_meters);
}

async function drawCircleOnMap2(map, centre_lat, centre_lng, radius_in_metres) {
  const { Circle } = await google.maps.importLibrary("maps");

  return new Circle({
    strokeColor: "#FF0000",
    strokeOpacity: 0.2,
    fillColor: "#FF0000",
    fillOpacity: 0.1,
    map: map,
    center: { lat: centre_lat, lng: centre_lng },
    radius: radius_in_metres,
  });
};
