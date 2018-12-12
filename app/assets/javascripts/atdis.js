//= require jquery-ui/widgets/datepicker
//= require jquery-ui/i18n/datepicker-en-AU.js

// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  // When this_selector is updated, update the option on the other_selector
  function setupDatePicker(this_selector, other_selector, option) {
    $(this_selector).datepicker({
      dateFormat: "yy-mm-dd",
      onClose: function(date) {
        $(other_selector).datepicker("option", option, date);
      }
    });
    if ($(this_selector).datepicker("getDate") != null) {
      var date = $(this_selector).datepicker("getDate");
      $(other_selector).datepicker("option", option, date);
    }
  }

  function setupDateRange(start_selector, end_selector) {
    setupDatePicker(start_selector, end_selector, "minDate");
    setupDatePicker(end_selector, start_selector, "maxDate");
  }

  setupDateRange("#feed_lodgement_date_start", "#feed_lodgement_date_end");
  setupDateRange("#feed_last_modified_date_start", "#feed_last_modified_date_end");

  $("#filter-heading").click(function(){
    $("#filters").toggle("fast");
    return false;
  })
})
