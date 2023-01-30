// This depends on there being a link with the id #geolocate with a
// .spinner inside of it that is hidden by default in the css

function getPosition(options) {
  return new Promise((resolve, reject) =>
    navigator.geolocation.getCurrentPosition(resolve, reject, options)
  );
}

function getAddressFromPosition(latitude, longitude) {
  return new Promise((resolve, reject) => {
    const latlng = new google.maps.LatLng(latitude, longitude);
    const geocoder = new google.maps.Geocoder();
    geocoder.geocode({'latLng': latlng}, (results, status) => {
      if (status == google.maps.GeocoderStatus.OK) {
        resolve(results[0].formatted_address);
      } else {
        reject(status);
      }
    });  
  });
}

window.addEventListener("DOMContentLoaded", function() {
  var geolocate = this.document.getElementById("geolocate");

  if (geolocate && navigator.geolocation) {
    geolocate.style.visibility = "visible";
  
    geolocate.addEventListener("click", function(e) {
      var link = this;
      var spinner = this.querySelector(".spinner");
      e.preventDefault();
      spinner.style.visibility = "visible";
      getPosition({enableHighAccuracy: true, timeout: 10000})
        .then((pos) => {
          getAddressFromPosition(pos.coords.latitude, pos.coords.longitude)
            .then((address) => {
              location.href = '/?q=' + encodeURIComponent(address);
            })
            .catch((err) => {
              spinner.style.visibility = "hidden";
              link.innerHTML = "Address lookup failed: " + err;
            });
        })
        .catch((err) => {
          spinner.style.visibility = "hidden";
          if (err.code == 1) { // User said no
            link.innerHTML = "You declined; please fill in the box above";
          } else if (err.code == 2) { // No position
            link.innerHTML = "Could not look up location";
          } else if (err.code == 3) { // Too long
            link.innerHTML = "No result returned";
          } else { // Unknown
            console.log(err);
            link.innerHTML = "Unknown error";
          }  
        });
    });
  }
});
