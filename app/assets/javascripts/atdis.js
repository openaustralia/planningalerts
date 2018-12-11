//= require jquery-ui/widgets/datepicker
//= require jquery-ui/i18n/datepicker-en-AU.js

// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  function setMinDate(selector, date) {
    $(selector).datepicker("option", "minDate", date);
  }
  function setMaxDate(selector, date) {
    $(selector).datepicker("option", "maxDate", date);
  }

  $("#feed_lodgement_date_start").datepicker({
    dateFormat: "yy-mm-dd",
    onClose: function(selectedDate) {
      setMinDate("#feed_lodgement_date_end", selectedDate);
    }
  });
  $("#feed_lodgement_date_end").datepicker({
    dateFormat: "yy-mm-dd",
    onClose: function(selectedDate) {
      setMaxDate("#feed_lodgement_date_start", selectedDate);
    }
  });
  $("#feed_last_modified_date_start").datepicker({
    dateFormat: "yy-mm-dd",
    onClose: function(selectedDate) {
      setMinDate("#feed_last_modified_date_end", selectedDate);
    }
  });
  $("#feed_last_modified_date_end").datepicker({
    dateFormat: "yy-mm-dd",
    onClose: function(selectedDate) {
      setMaxDate("#feed_last_modified_date_start", selectedDate);
    }
  });

  if ($("#feed_lodgement_date_start").datepicker("getDate") != null) {
    setMinDate("#feed_lodgement_date_end", $("#feed_lodgement_date_start").datepicker("getDate"));
  }
  if ($("#feed_lodgement_date_end").datepicker("getDate") != null) {
    setMaxDate("#feed_lodgement_date_start", $("#feed_lodgement_date_end").datepicker("getDate"));
  }
  if ($("#feed_last_modified_date_start").datepicker("getDate") != null) {
    setMinDate("#feed_last_modified_date_end", $("#feed_last_modified_date_start").datepicker("getDate"));
  }
  if ($("#feed_last_modified_date_end").datepicker("getDate") != null) {
    setMaxDate("#feed_last_modified_date_start", $("#feed_last_modified_date_end").datepicker("getDate"));
  }

  $("#filter-heading").click(function(){
    $("#filters").toggle("fast");
    return false;
  })
})
