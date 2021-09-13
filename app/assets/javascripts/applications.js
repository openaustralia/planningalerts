// Javascript used on applications pages
$('#add_comment_address_input a').click(function(e) {
  e.preventDefault();
  $('#faq_commenting_address').slideToggle('fast');
});

$('#add_comment_text_input a').click(function(e) {
  e.preventDefault();
  $('#disclosure_explanation').slideToggle('fast');
});

$('a.hideable').click(function(e) {
  e.preventDefault();
  target = $(e.target).attr("data-target");
  $(target).slideToggle('fast');
});
