//= require jquery.ui.autocomplete.js
//= require jquery.ui.autocomplete.html.js
//= require address_autocomplete.js
//= require geolocation

$("#menu .toggle").click(function(){
  $("#menu ul").slideToggle("fast", function(){
    $("#menu ul").toggleClass("hidden").css("display", "");
  });
});
