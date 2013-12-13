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

                var text = prediction.description
                if (offset == 0) {
                    var html = "<strong>" + text.slice(0, length) + "</strong>" + text.slice(length);
                }
                else {
                    var html = text;
                }

                return({label: html, value: text});
            }));
        });
    }
});