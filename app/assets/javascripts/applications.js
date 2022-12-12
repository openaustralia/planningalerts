// Javascript used on applications pages

$('a.hideable').click(function(e) {
  e.preventDefault();
  var target = $(e.target).attr("data-target");
  $(target).slideToggle('fast');
});
