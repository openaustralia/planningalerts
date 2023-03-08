//= require maps/pano
//= require maps/alert_map
//= require maps/geocoding_map
//= require maps/basic_map_with_marker

window.addEventListener("DOMContentLoaded", function() {
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
});
