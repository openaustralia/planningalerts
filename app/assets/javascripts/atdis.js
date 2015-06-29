//= require jquery-ui/datepicker
//= require jquery-ui/datepicker-en-AU.js

// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  $("#feed_lodgement_date_start").datepicker({
    dateFormat: "yy-mm-dd",
    onClose: function(selectedDate) {
      $("#feed_lodgement_date_end").datepicker("option", "minDate", selectedDate);
    }
  });
  $("#feed_lodgement_date_end").datepicker({
    dateFormat: "yy-mm-dd",
    onClose: function(selectedDate) {
      $("#feed_lodgement_date_start").datepicker("option", "maxDate", selectedDate);
    }
  });
  $("#feed_last_modified_date_start").datepicker({
    dateFormat: "yy-mm-dd",
    onClose: function(selectedDate) {
      $("#feed_last_modified_date_end").datepicker("option", "minDate", selectedDate);
    }
  });
  $("#feed_last_modified_date_end").datepicker({
    dateFormat: "yy-mm-dd",
    onClose: function(selectedDate) {
      $("#feed_last_modified_date_start").datepicker("option", "maxDate", selectedDate);
    }
  });

  if ($("#feed_lodgement_date_start").datepicker("getDate") != null) {
    $("#feed_lodgement_date_end").datepicker("option", "minDate", $("#feed_lodgement_date_start").datepicker("getDate"));
  }
  if ($("#feed_lodgement_date_end").datepicker("getDate") != null) {
    $("#feed_lodgement_date_start").datepicker("option", "maxDate", $("#feed_lodgement_date_end").datepicker("getDate"));
  }
  if ($("#feed_last_modified_date_start").datepicker("getDate") != null) {
    $("#feed_last_modified_date_end").datepicker("option", "minDate", $("#feed_last_modified_date_start").datepicker("getDate"));
  }
  if ($("#feed_last_modified_date_end").datepicker("getDate") != null) {
    $("#feed_last_modified_date_start").datepicker("option", "maxDate", $("#feed_last_modified_date_end").datepicker("getDate"));
  }

  $("#filter-heading").click(function(){
    $("#filters").toggle("fast");
    return false;
  })
})
