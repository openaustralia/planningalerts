//= require maps/pano_utils

function initialisePano(elem) {
  var lat = Number(elem.dataset.lat);
  var lng = Number(elem.dataset.lng);
  var address = elem.dataset.address;

  // Can't yet figure out how to make the POV point at the marker
  var pointToLookAt = new google.maps.LatLng(lat, lng);
  var myPano = new  google.maps.StreetViewPanorama(elem,
    {position: pointToLookAt, navigationControl: false, addressControl: false, zoom: 0, scrollwheel: false, fullscreenControl: false, linksControl: false});
  google.maps.event.addListener(myPano, 'position_changed', function() {
    // Orient the camera to face the position we're interested in
    var angle = computeAngle(pointToLookAt, myPano.getPosition());
    myPano.setPov({heading:angle, pitch:0, zoom:1});
  });
  var panoMarker = new google.maps.Marker({position: pointToLookAt, title: address});
  panoMarker.setMap(myPano);
}
