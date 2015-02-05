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
  public_key = $('#button-pro-signup').attr('data-key');
  email = $('#button-pro-signup').attr("data-email");

  var handler = StripeCheckout.configure({
    key: public_key,
    image: '/square-image.png',
    token: function(response) {
      var tokenInput = $("<input type=hidden name=stripeToken />").val(response.id);
      var emailInput = $("<input type=hidden name=stripeEmail />").val(response.email);
      $("#subscription-payment-form").append(tokenInput).append(emailInput).submit();
    }
  });

  $('#button-pro-signup').on('click', function(e) {
    // Open Checkout with further options
    handler.open({
      name: 'PlanningAlerts',
      amount: 9900,
      currency: 'AUD',
      email: email
    });
    e.preventDefault();

    // TODO: send GA event track
  });

  // Close Checkout on page navigation
  $(window).on('popstate', function() {
    handler.close();
  });
}
