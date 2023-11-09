//= require maps/alert_map
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
