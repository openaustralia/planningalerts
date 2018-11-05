$( document ).ready(function() {
  // check if the Google Analytics function is available
  if (typeof ga == 'function') {
    // GA Tracking of comment process
    $('.link-to-comment-form').click(function(e) {
      ga('send', 'event', 'comments', 'click link to go to comment form');
    });

    $('#comment-action-inputgroup input[type="submit"]').click(function(e) {
      ga('send', 'event', 'comments', 'click submit new comment');
    });

    $('#add_comment_text_input .inline-hints a').click(function(e) {
      ga('send', 'event', 'comments', 'click link for info about donation disclosure');
    });

    $('#add_comment_address_input .inline-hints a').click(function(e) {
      ga('send', 'event', 'comments', 'click link for info about why your address is necessay');
    });

    if ($('.notice-comment-confirmed').length) {
      ga('send', 'event', 'comments', 'comment confirm message displayed');
    }

    if ($('#comments-area .error').length) {
      ga('send', 'event', 'comments', 'comment form error message displayed');
    }

    $('.notice-comment-confirmed .button-facebook').click(function(e) {
      ga('send', 'event', 'comments', 'click Facebook share', 'from comment confirmation');
    });

    // Creating Alerts
    $('#new_alert input[type="submit"]').click(function(e) {
      ga('send', 'event', 'alerts', 'click submit create alert');
    });

    if ($('#new_alert .error').length) {
      ga('send', 'event', 'alerts', 'alert form error messages displayed');
    }

    if ($('#alert-email-confirm-prompt').length) {
      ga('send', 'event', 'alerts', 'alert prompt to confirm in email displayed');
    }

    // Searching for applications
    $('.address-search input[type="submit"]').click(function(e) {
      ga('send', 'event', 'search', 'click submit address search');
    });

    $('.address-search #geolocate').click(function(e) {
      ga('send', 'event', 'search', 'click locate me link');
    });

    if ($('.address-search .error').length) {
      ga('send', 'event', 'search', 'address search form error message displayed');
    }

    // Updating alert radius
    $('.map-settings input#size_s').click(function(e) {
      ga('send', 'event', 'update alert settings', 'click size option My street');
    });

    $('.map-settings input#size_m').click(function(e) {
      ga('send', 'event', 'update alert settings', 'click size option My neighbourhood');
    });

    $('.map-settings input#size_l').click(function(e) {
      ga('send', 'event', 'update alert settings', 'click size option My suburb');
    });

    $('.map-settings input[type="submit"]').click(function(e) {
      ga('send', 'event', 'update alert settings', 'click submit Update size');
    });

    // Donations
    $('.donate-link-header').click(function(e) {
      ga('send', 'event', 'donate', 'click donate', 'header menu donate item');
    });

    $('.donations-banner .button').click(function(e) {
      ga('send', 'event', 'donate', 'click donate', 'footer donation banner button');
    });

    // Regular donations
    $('#button-pro-signup').click(function(e) {
      ga('send', 'event', 'donate', 'click donate each month button');
    });

    if ($('.donations-notice').length) {
      ga('send', 'event', 'donate', 'donations form error message displayed');
    }
  }
});
