//= require jquery-ui/widgets/autocomplete
//= require jquery-ui/widgets/menu
//= require jquery.ui.autocomplete.html.js
//= require address_autocomplete.js
//= require geolocation
//= require applications
//= require event_tracking

$("#menu .toggle").click(function(){
  $("#menu ul").slideToggle("fast", function(){
    $("#menu ul").toggleClass("hidden").css("display", "");
  });
});
