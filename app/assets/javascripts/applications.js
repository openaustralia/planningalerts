// Javascript used on applications pages
$('#comment_address_input a').click(function(e) {
  e.preventDefault();
  $('#faq_commenting_address').slideToggle('fast');
});

// GA Tracking of comment process
$( document ).ready(function() {
  // check if the Google Analytics function is available
  if (typeof ga == 'function') {
    if ($('.notice-comment-confirmed').length) {
      ga('send', 'event', 'comments', 'comment confirm message displayed');
    }
  }
});
