//= require jquery.ui.autocomplete.js
//= require jquery.ui.autocomplete.html.js
//= require address_autocomplete.js
//= require geolocation

$("#menu .toggle").click(function(){
  $("#menu ul").slideToggle("fast", function(){
    $("#menu ul").toggleClass("hidden").css("display", "");
  });
});

if ("#button-pro-signup".length) {
  var handler = StripeCheckout.configure({
    key: 'pk_test_7waRLEZaqjxyoxtZzlHtliMS',
    image: '/square-image.png',
    token: function(token) {
      // Use the token to create the charge with a server-side script.
      // You can access the token ID with `token.id`
    }
  });

  $('#button-pro-signup').on('click', function(e) {
    // Open Checkout with further options
    handler.open({
      name: 'PlanningAlerts',
      amount: 9900,
      currency: 'AUD'
    });
    e.preventDefault();

    // TODO: send GA event track
  });

  // Close Checkout on page navigation
  $(window).on('popstate', function() {
    handler.close();
  });
}
