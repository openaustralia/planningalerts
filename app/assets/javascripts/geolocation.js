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

function getAddress() {
  return new Promise((resolve, reject) => {
    getPosition({enableHighAccuracy: true, timeout: 10000})
    .then((pos) => {
      getAddressFromPosition(pos.coords.latitude, pos.coords.longitude)
        .then((address) => {
          resolve(address);
        })
        .catch((err) => {
          reject("Address lookup failed: " + err);
        });
    })
    .catch((err) => {
      if (err.code == 1) { // User said no
        reject("You declined; please fill in the box above");
      } else if (err.code == 2) { // No position
        reject("Could not look up location");
      } else if (err.code == 3) { // Too long
        reject("No result returned");
      } else { // Unknown
        reject("Unknown error");
      }  
    });  
  })
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
      getAddress()
        .then((address) => {
          location.href = '/?q=' + encodeURIComponent(address);
        })
        .catch((err) => {
          spinner.style.visibility = "hidden";
          link.innerHTML = err;
        })
    });
  }
});
