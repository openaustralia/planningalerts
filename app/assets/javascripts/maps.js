//= require maps/pano
//= require maps/alert_map
//= require maps/geocoding_map
//= require maps/basic_map_with_marker
//= require maps/address_autocomplete.js

// This function is called after the google maps api is fully loaded. So, we can safely set things
// up to use it here
function initialiseAllMaps() {
  // Map on the application page
  var map_div = document.querySelector("#map_div.application");
  if (map_div) initialiseBasicMapWithMarker(map_div);

  // Streetview on the application page
  var pano = document.querySelector("#pano");
  if (pano) initialisePano(pano);

  // Alert radius map on the edit alert page
  var map_div = document.querySelector("#map_div.alert-radius");
  if (map_div) {
    var circle = initialiseAlertMap(map_div);
    document.querySelector(".sizes").addEventListener("change", function(e) {
      circle.setRadius(parseInt(e.target.value));
    });
  }

  document.querySelectorAll(".map").forEach(initialiseAlertMap);

  var map_div = document.getElementById('geocoding-map');
  if (map_div) initialiseGeocodingMap(map_div);

  if (document.querySelectorAll('.address-autocomplete-input').length) {
    initAutoComplete();
  }

  this.document.querySelectorAll(".authority-map").forEach(function(e) {
    var map = new google.maps.Map(e,  { zoom: 4, center: { lat: -28, lng: 137 },
      fullscreenControl: false, streetViewControl: false, backgroundColor: "#d1e6d9" });

    var json = e.dataset.json;
    var sw_lng = Number(e.dataset.swLng);
    var sw_lat = Number(e.dataset.swLat);
    var ne_lng = Number(e.dataset.neLng);
    var ne_lat = Number(e.dataset.neLat);

    var sw = new google.maps.LatLng(sw_lat, sw_lng);
    var ne = new google.maps.LatLng(ne_lat, ne_lng);
    var bounds = new google.maps.LatLngBounds(sw, ne);

    map.fitBounds(bounds);
    map.data.loadGeoJson(json);
  });  
}

window.initialiseAllMaps = initialiseAllMaps;
