//= require address_autocomplete.js
//= require geolocation
//= require event_tracking
//= require maps
// Need ujs for confirmation on buttons
//= require rails-ujs

$('.hideable').click(function(e) {
  e.preventDefault();
  var target = $(e.target).attr("data-target");
  $(target).toggleClass("hideable-target-show");
});
