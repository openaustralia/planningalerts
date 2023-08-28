//= require maps/alert_map

// This function is called after the google maps api is fully loaded. So, we can safely set things
// up to use it here
function initialiseAllMaps() {
  window.dispatchEvent(new Event('map-loaded'));
}

window.initialiseAllMaps = initialiseAllMaps;
