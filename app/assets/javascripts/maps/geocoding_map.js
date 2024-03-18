function initialiseGeocodingMap(map_div) {
  var googleLatLng = {lat: Number(map_div.dataset.googleLat), lng: Number(map_div.dataset.googleLng)};
  var mappifyLatLng = {lat: Number(map_div.dataset.mappifyLat), lng: Number(map_div.dataset.mappifyLng)};

  var map = new google.maps.Map(map_div, { zoom: 13, center: googleLatLng });

  // TODO: Generalise to any number of geocoder results

  var googleInfowindow = new google.maps.InfoWindow({
    content: map_div.dataset.googleHtml
  });

  var mappifyInfowindow = new google.maps.InfoWindow({
    content: map_div.dataset.mappifyHtml
  });

  var googleMarker = new google.maps.Marker({
    position: googleLatLng,
    map: map,
    title: 'Google',
    label: "G"
  });

  var mappifyMarker = new google.maps.Marker({
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
