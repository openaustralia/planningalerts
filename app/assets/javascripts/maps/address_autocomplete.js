function initAutoComplete() {
  var input = document.querySelector(".address-autocomplete-input");
  var options = {
    componentRestrictions: {country: "au"},
    types: ["address"]
  };

  var autocomplete = new google.maps.places.Autocomplete(input, options);

  autocomplete.addListener('place_changed', function() {
    // The "form.one-field" only exists on the address search on the landing page
    // We only want the form to be submitted automatically on that page
    var form = document.querySelector("form.one-field");
    if (form) form.submit();
  });
}
