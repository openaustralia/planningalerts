function initAutoComplete() {
  var input = document.querySelector(".address-autocomplete-input");
  var options = {
    componentRestrictions: {country: "au"},
    types: ["address"]
  };

  var autocomplete = new google.maps.places.Autocomplete(input, options);

  autocomplete.addListener('place_changed', function() {
    $("form.one-field").submit();
  });
}

if (document.querySelectorAll('.address-autocomplete-input').length) {
  initAutoComplete();
}
