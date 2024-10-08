//= require pano_utils

async function initialisePano(elem, params) {
  const { StreetViewPanorama } = await google.maps.importLibrary("streetView");
  const { Marker } = await google.maps.importLibrary("marker");
  const { LatLng } = await google.maps.importLibrary("core");

  // Can't yet figure out how to make the POV point at the marker
  var pointToLookAt = new LatLng(params.lat, params.lng);
  var myPano = new StreetViewPanorama(elem,
    {
      position: pointToLookAt,
      navigationControl: false,
      addressControl: false,
      zoom: 0,
      scrollwheel: false,
      fullscreenControl: false,
      linksControl: false
    });
  myPano.addListener('position_changed', function() {
    // Orient the camera to face the position we're interested in
    var angle = computeAngle(pointToLookAt, myPano.getPosition());
    myPano.setPov({heading:angle, pitch:0, zoom:1});
  });
  var panoMarker = new Marker({position: pointToLookAt, title: params.address});
  panoMarker.setMap(myPano);
}

async function initialiseBasicMapWithMarker(map_div, params) {
  const { Map } = await google.maps.importLibrary("maps");
  const { Marker } = await google.maps.importLibrary("marker");

  var center = { lat: params.lat, lng: params.lng };
  var map = new Map(
    map_div,
    {
      zoom: params.zoom,
      center: center,
      fullscreenControl: false,
      streetViewControl: false,
      backgroundColor: "#d1e6d9"
    }
  );
  new Marker({
    position: center,
    map: map,
    title: params.address
  });

  return map;
}

async function initialiseAlertMap(map_div, params) {
  var map = await initialiseBasicMapWithMarker(map_div, params);
  return drawCircleOnMap(map, params.lat, params.lng, params.radius_meters);
}

async function drawCircleOnMap(map, centre_lat, centre_lng, radius_in_metres) {
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

async function initialiseAuthorityMap(el, params) {
  const { Map } = await google.maps.importLibrary('maps');
  const { LatLng, LatLngBounds } = await google.maps.importLibrary('core');
  var map = new Map(el,
    {
      zoom: 4,
      center: { lat: -28, lng: 137 },
      fullscreenControl: false,
      streetViewControl: false,
      backgroundColor: '#d1e6d9'
    });
  var sw = new LatLng(params.sw.lat, params.sw.lng);
  var ne = new LatLng(params.ne.lat, params.ne.lng);
  var bounds = new LatLngBounds(sw, ne);
  map.fitBounds(bounds);
  map.addListener('tilesloaded', function() {
    // Only load the boundary once the map has displayed. Do this because loading the boundary can
    // take a while and the map is already showing roughly where the council is without the boundary
    // and so it is immediately useful
    map.data.loadGeoJson(params.json);
});
}

async function initialiseGeocodingMap(map_div) {
  const { Map, InfoWindow } = await google.maps.importLibrary('maps');
  const { Marker } = await google.maps.importLibrary("marker");

  var g = JSON.parse(map_div.dataset.google);
  var m = JSON.parse(map_div.dataset.mappify);
  var googleLatLng = {lat: g.lat, lng: g.lng};
  var mappifyLatLng = {lat: m.lat, lng: m.lng};

  console.log("googleLatLng", googleLatLng);
  console.log("mappifyLatLng", mappifyLatLng);

  var map = new Map(map_div, { zoom: 13, center: googleLatLng });

  // TODO: Generalise to any number of geocoder results

  var googleInfowindow = new InfoWindow({
    content: g.html
  });

  var mappifyInfowindow = new InfoWindow({
    content: m.html
  });

  var googleMarker = new Marker({
    position: googleLatLng,
    map: map,
    title: 'Google',
    label: "G"
  });

  var mappifyMarker = new Marker({
    position: mappifyLatLng,
    map: map,
    title: 'Mappify',
    label: "M"
  });

  googleMarker.addListener('click', function() {
    googleInfowindow.open(map, googleMarker);
  });

  mappifyMarker.addListener('click', function() {
    mappifyInfowindow.open(map, mappifyMarker);
  });
}
