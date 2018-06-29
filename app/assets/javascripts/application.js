//= require jquery-ui/autocomplete
//= require jquery-ui/menu
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

function updateFormAmount(new_amount) {
  $('#button-pro-signup').attr("data-amount", new_amount * 100);

  if (parseInt(new_amount) < 1 || new_amount == "" ) {
    amount_text = "Donate";
  } else {
   amount_text = "Donate $" + new_amount;
  };
  if ($('#monthly').prop("checked")) {
    amount_text = amount_text + " each month";
  } else {
    amount_text = amount_text + " once";
  };
  $('#button-pro-signup').text(amount_text);
};

if ($("#button-pro-signup").length && typeof(StripeCheckout) === "object") {
  $('#button-pro-signup').prop("disabled", "false");
  $('#button-pro-signup + .no-js-message').addClass("hide");

  if ($('.amount-setter-input input').length) {
    updateFormAmount($('.amount-setter-input input').val());

    $('.amount-setter-input input').bind('input', function() {
      updateFormAmount($(this).val());

      if ($(this).val() < 1) {
        $('#button-pro-signup').prop("disabled", true);
      } else {
        $('#button-pro-signup').prop("disabled", false);
      };
    });
    $('#monthly').bind('change', function() {
      updateFormAmount($('.amount-setter-input input').val());
    });
  }

  if (typeof($('#button-pro-signup').attr('data-key')) !== "undefined") {
    public_key = $('#button-pro-signup').attr('data-key');
  } else {
    public_key = "";
  }

  email = $('#button-pro-signup').attr("data-email");

  var handler = StripeCheckout.configure({
    key: public_key,
    token: function(response) {
      var tokenInput = $("<input type=hidden name=stripeToken />").val(response.id);
      var emailInput = $("<input type=hidden name=stripeEmail />").val(response.email);
      $("#donation-payment-form").append(tokenInput).append(emailInput).submit();
      $('#button-pro-signup').fadeOut('fast', function() {
        var processingNotice = $("<p class='form-processing'>Processing ...</p>").fadeIn('slow');
        $("#donation-payment-form").append(processingNotice);
      });
    }
  });

  $('#button-pro-signup').on('click', function(e) {
    amount = $('#button-pro-signup').attr("data-amount");

    formOptions = {
      image: '/assets/street_map.png',
      name: 'PlanningAlerts',
      amount: parseInt(amount),
      currency: 'AUD',
      panelLabel: "Donate {{amount}}/mo"
    };
    if ($("#monthly")) {formOptions.panelLabel = "Donate {{amount}}"};
    if (typeof email !== "undefined") { formOptions.email = email };

    // Open Checkout with further options
    handler.open(formOptions);
    e.preventDefault();
  });

  // enable the button
  $('#button-pro-signup').attr('disabled', false);

}
