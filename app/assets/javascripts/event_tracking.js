window.addEventListener("DOMContentLoaded", function() {
  // check if the Google Analytics function is available
  if (typeof ga == 'function') {
    // Shorthand for what we used to do with jquery
    function clicks(selector, f) {
      document.querySelectorAll(selector).forEach(function(elem) {
        elem.addEventListener("click", f);
      });
    }

    // GA Tracking of comment process
    clicks('.link-to-comment-form', function(e) {
      ga('send', 'event', 'comments', 'click link to go to comment form');
    });

    clicks('#comment-action-inputgroup input[type="submit"]', function(e) {
      ga('send', 'event', 'comments', 'click submit new comment');
    });

    clicks('#comment_text_input .inline-hints a', function(e) {
      ga('send', 'event', 'comments', 'click link for info about donation disclosure');
    });

    clicks('#comment_address_input .inline-hints a', function(e) {
      ga('send', 'event', 'comments', 'click link for info about why your address is necessay');
    });

    if (document.querySelectorAll('.notice-comment-confirmed').length) {
      ga('send', 'event', 'comments', 'comment confirm message displayed');
    }

    if (document.querySelectorAll('#comments-area .error').length) {
      ga('send', 'event', 'comments', 'comment form error message displayed');
    }

    clicks('.notice-comment-confirmed .button-facebook', function(e) {
      ga('send', 'event', 'comments', 'click Facebook share', 'from comment confirmation');
    });

    // Creating Alerts
    clicks('#new_alert input[type="submit"]', function(e) {
      ga('send', 'event', 'alerts', 'click submit create alert');
    });

    if (document.querySelectorAll('#new_alert .error').length) {
      ga('send', 'event', 'alerts', 'alert form error messages displayed');
    }

    if (document.querySelectorAll('#alert-email-confirm-prompt').length) {
      ga('send', 'event', 'alerts', 'alert prompt to confirm in email displayed');
    }

    // Searching for applications
    clicks('.address-search input[type="submit"]', function(e) {
      ga('send', 'event', 'search', 'click submit address search');
    });

    clicks('.address-search .geolocate', function(e) {
      ga('send', 'event', 'search', 'click locate me link');
    });

    if (document.querySelectorAll('.address-search .error').length) {
      ga('send', 'event', 'search', 'address search form error message displayed');
    }

    // Updating alert radius
    clicks('.map-settings input#size_s', function(e) {
      ga('send', 'event', 'update alert settings', 'click size option My street');
    });

    clicks('.map-settings input#size_m', function(e) {
      ga('send', 'event', 'update alert settings', 'click size option My neighbourhood');
    });

    clicks('.map-settings input#size_l', function(e) {
      ga('send', 'event', 'update alert settings', 'click size option My suburb');
    });

    clicks('.map-settings input[type="submit"]', function(e) {
      ga('send', 'event', 'update alert settings', 'click submit Update size');
    });

    // Donations
    clicks('.donate-link-header', function(e) {
      ga('send', 'event', 'donate', 'click donate', 'header menu donate item');
    });

    clicks('.donations-banner .button', function(e) {
      ga('send', 'event', 'donate', 'click donate', 'footer donation banner button');
    });

    // Regular donations
    clicks('#button-pro-signup', function(e) {
      ga('send', 'event', 'donate', 'click donate each month button');
    });

    if (document.querySelectorAll('.donations-notice').length) {
      ga('send', 'event', 'donate', 'donations form error message displayed');
    }
  }
});
