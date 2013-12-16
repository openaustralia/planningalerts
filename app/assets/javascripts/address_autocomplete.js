var service = new google.maps.places.AutocompleteService();

$("#alert_address,#q").autocomplete({
    html: true,
    source: function(request, response) {
        service.getPlacePredictions({
            input: request.term,
            componentRestrictions: {country: "au"},
            types: ["geocode"]
        }, function(predictions, status){
            response($.map(predictions, function(prediction){
                // Just highlight the first matched substring
                var length = prediction.matched_substrings[0].length;
                var offset = prediction.matched_substrings[0].offset;
                // Remove Australia from the list to make a slightly shorter version of the text
                textArray = $.map(prediction.terms.slice(0,-1), function(term){
                    return(term.value);
                });
                // Translate name of state to shorter version
                state = textArray[textArray.length - 1];
                switch(state) {
                    case "Australian Capital Territory": state = "ACT"; break;
                    case "New South Wales": state = "NSW"; break;
                    case "Northern Territory": state = "NT"; break;
                    case "Queensland": state = "QLD"; break;
                    case "South Australia": state = "SA"; break;
                    case "Tasmania": state = "TAS"; break;
                    case "Victoria": state = "VIC"; break;
                    case "Western Australia": state = "WA"; break;
                }
                // Don't use comma to separate state from rest of address to behave the same as the geocoder
                text = textArray.slice(0,-1).join(", ") + " " + state
                var html = text.slice(0, offset) +
                    "<strong>" + text.slice(offset, offset+length) + "</strong>" +
                    text.slice(offset+length);

                return({label: html, value: text});
            }));
        });
    },
    select: function( event, ui ) {
        // If we're on the home page (which has a form with one field) make selecting an address submit the form
        $("form.one-field").submit();
    }
});