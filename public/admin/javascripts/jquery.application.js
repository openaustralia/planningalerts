$(document).ready(function() {
  $("#quicksearch").searchField();
  $('.resource :input', document.myForm).bind("change", function() { setConfirmUnload(true); });
  $("a.fancybox").fancybox({
    'titlePosition': 'over',
    'type': 'image'
  });
});

function setConfirmUnload(on) {
  window.onbeforeunload = (on) ? unloadMessage : null;
}

function unloadMessage() {
  return "You have entered new data on this page. If you navigate away from this page without first saving your data, the changes will be lost.";
}
