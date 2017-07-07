$(document).ready(function(){
  $('.remove_fields').live('click',function(){
    var num = $(".nested-fields").length - 1;
    document.getElementById("counts").value = "Submit " + (num) + " new councillors"
  });

  $('#add_button').live('click',function(){
    var num = $(".nested-fields").length;
    document.getElementById("counts").value = "Submit " + (num) + " new councillors"
  });



});
