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

// TODO: Once a409874 is merged, remove the test search for the "#q" selector
if (document.querySelectorAll("#q").length || document.querySelectorAll('.address-autocomplete-input').length) {
  initAutoComplete();
}
