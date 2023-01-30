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

async function getAddress() {
  try {
    var pos = await getPosition({enableHighAccuracy: true, timeout: 10000});
  } catch(err) {
    if (err.code == 1) { // User said no
      throw("You declined; please fill in the box above");
    } else if (err.code == 2) { // No position
      throw("Could not look up location");
    } else if (err.code == 3) { // Too long
      throw("No result returned");
    } else { // Unknown
      throw("Unknown error");
    }
  }

  try {
    return await getAddressFromPosition(pos.coords.latitude, pos.coords.longitude);
  } catch(err) {
    throw("Address lookup failed: " + err);
  }
}
