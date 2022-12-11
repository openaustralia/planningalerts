//= require flatpickr

// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  // When this_selector is updated, update the option on the other_selector
  function setupDatePicker(this_selector, other_selector, option) {
    flatpickr(this_selector, {
      onClose: function(selectedDates, dateStr, instance) {
        document.querySelector(other_selector)._flatpickr.set(option, dateStr);
      }
    });
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
