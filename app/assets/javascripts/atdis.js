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

  function setupDatePicker(selector, onClose) {
    $(selector).datepicker({
      dateFormat: "yy-mm-dd",
      onClose: onClose
    });
  }

  function setupStartDate(start_selector, end_selector) {
    setupDatePicker(start_selector, function(selectedDate) {
      setMinDate(end_selector, selectedDate);
    });
    if ($(start_selector).datepicker("getDate") != null) {
      setMinDate(end_selector, $(start_selector).datepicker("getDate"));
    }
  }

  function setupEndDate(start_selector, end_selector) {
    setupDatePicker(end_selector, function(selectedDate) {
      setMaxDate(start_selector, selectedDate);
    });
    if ($(end_selector).datepicker("getDate") != null) {
      setMaxDate(start_selector, $(end_selector).datepicker("getDate"));
    }
  }

  function setupDateRange(start_selector, end_selector) {
    setupStartDate(start_selector, end_selector);
    setupEndDate(start_selector, end_selector);
  }

  setupDateRange("#feed_lodgement_date_start", "#feed_lodgement_date_end");
  setupDateRange("#feed_last_modified_date_start", "#feed_last_modified_date_end");

  $("#filter-heading").click(function(){
    $("#filters").toggle("fast");
    return false;
  })
})
