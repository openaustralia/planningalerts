// This depends on there being a link with the id #geolocate with a
// .spinner inside of it that is hidden by default in the css

$(function() {
  if (navigator.geolocation) {
    $("#geolocate").css('visibility', 'visible');
  }

  $("#geolocate").click(function(e){
    var link = $(this);
    e.preventDefault();
    link.find(".spinner").css('visibility', 'visible');
    navigator.geolocation.getCurrentPosition(function(pos) {
      var latlng = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
      geocoder = new google.maps.Geocoder();
      geocoder.geocode({'latLng': latlng}, function(results, status){
        if (status == google.maps.GeocoderStatus.OK) {
          console.log(results[0].formatted_address);
          location.href = '/?q=' + encodeURIComponent(results[0].formatted_address);
        } else {
          link.find(".spinner").css('visibility', 'hidden');
          link.html("Address lookup failed: " + status);
        }
      });
    }, function(err) {
      link.find(".spinner").css('visibility', 'hidden');
      if (err.code == 1) { // User said no
          link.html("You declined; please fill in the box above");
      } else if (err.code == 2) { // No position
          link.html("Could not look up location");
      } else if (err.code == 3) { // Too long
          link.html("No result returned");
      } else { // Unknown
          link.html("Unknown error");
      }
    }, {enableHighAccuracy: true, timeout: 10000});
  });
});
