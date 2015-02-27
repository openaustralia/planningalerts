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
  amount = $('#button-pro-signup').attr("data-amount");
  submit_block = $('.payment-submit-block');

  var handler = StripeCheckout.configure({
    key: public_key,
    image: '/square-image.png',
    token: function(response) {
      var tokenInput = $("<input type=hidden name=stripeToken />").val(response.id);
      var emailInput = $("<input type=hidden name=stripeEmail />").val(response.email);
      $("#subscription-payment-form").append(tokenInput).append(emailInput).submit();
      submit_block.fadeOut('fast', function() {
        var processingNotice = $("<p class='form-processing'>Processing ...</p>").fadeIn('slow');
        $("#subscription-payment-form").append(processingNotice);
      });
    }
  });

  $('#button-pro-signup').on('click', function(e) {
    // Open Checkout with further options
    handler.open({
      image: '/assets/street_map.png',
      name: 'PlanningAlerts',
      amount: amount,
      currency: 'AUD',
      email: email,
      panelLabel: "Subscribe now {{amount}}/mo"
    });
    e.preventDefault();

    // send GA event track
    ga('send', 'event', 'subscriptions', 'click subscribe button');
  });

  // Close Checkout on page navigation
  $(window).on('popstate', function() {
    handler.close();
  });

  // enable the button
  $('#button-pro-signup').attr('disabled', false);
}
