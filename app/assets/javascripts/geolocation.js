// This depends on there being a link with the id #geolocate with a
// .spinner inside of it that is hidden by default in the css

window.addEventListener("DOMContentLoaded", function() {
  var geolocate = this.document.getElementById("geolocate");

  if (geolocate && navigator.geolocation) {
    geolocate.style.visibility = "visible";
  
    geolocate.addEventListener("click", function(e) {
      var link = this;
      var spinner = this.querySelector(".spinner");
      e.preventDefault();
      spinner.style.visibility = "visible";
      navigator.geolocation.getCurrentPosition(function(pos) {
        var latlng = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
        geocoder = new google.maps.Geocoder();
        geocoder.geocode({'latLng': latlng}, function(results, status){
          if (status == google.maps.GeocoderStatus.OK) {
            location.href = '/?q=' + encodeURIComponent(results[0].formatted_address);
          } else {
            spinner.style.visibility = "hidden";
            link.innerHTML = "Address lookup failed: " + status;
          }
        });
      }, function(err) {
        spinner.style.visibility = "hidden";
        if (err.code == 1) { // User said no
          link.innerHTML = "You declined; please fill in the box above";
        } else if (err.code == 2) { // No position
          link.innerHTML = "Could not look up location";
        } else if (err.code == 3) { // Too long
          link.innerHTML = "No result returned";
        } else { // Unknown
          link.innerHTML = "Unknown error";
        }
      }, {enableHighAccuracy: true, timeout: 10000});
    });
  }
});
