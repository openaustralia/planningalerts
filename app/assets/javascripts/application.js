//= require address_autocomplete.js
//= require geolocation
//= require event_tracking
//= require maps
// Need ujs for confirmation on buttons
//= require rails-ujs

document.querySelectorAll(".hideable").forEach(function(e) {
  e.addEventListener("click", function(e) {
    e.preventDefault();
    var target = e.target.getAttribute("data-target");
    document.querySelector(target).classList.toggle("hideable-target-show");  
  })
})

document.querySelectorAll(".dropdown-toggle").forEach(function(e) {
  e.addEventListener("click", function(e) {
    e.preventDefault();
    console.log("Clicked");
    console.log(e.target.parentElement);
    // TODO: Should really check that parent has dropdown class as we would expect
    e.target.parentElement.classList.toggle("open");
  })
})
