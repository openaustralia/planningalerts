//= require jquery-ui/widgets/menu
//= require address_autocomplete.js
//= require geolocation
//= require applications
//= require event_tracking
//= require maps
// Need ujs for confirmation on buttons
//= require jquery_ujs

$("#menu .toggle").click(function(){
  $("#menu ul").slideToggle("fast", function(){
    $("#menu ul").toggleClass("hidden").css("display", "");
  });
});
