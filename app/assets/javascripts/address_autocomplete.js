function initAutoComplete() {
  var input = document.getElementById('q');
  var options = {
    componentRestrictions: {country: "au"},
    types: ["address"]
  };

  var autocomplete = new google.maps.places.Autocomplete(input, options);

  autocomplete.addListener('place_changed', function() {
    $("form.one-field").submit();
  })
}

initAutoComplete()
