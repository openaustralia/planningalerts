function initAutoComplete() {
  var input = document.getElementById('q');
  var options = {
    componentRestrictions: {country: "au"},
    types: ["address"]
  };

  var autocomplete = new google.maps.places.Autocomplete(input, options);
}

initAutoComplete()
