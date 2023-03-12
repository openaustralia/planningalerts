//= require maps
//= require geolocation
//= require event_tracking
// Need ujs for confirmation on buttons
//= require rails-ujs

document.querySelectorAll(".hideable").forEach(function(e) {
  e.addEventListener("click", function(e) {
    e.preventDefault();
    var target = e.target.getAttribute("data-target");
    document.querySelector(target).classList.toggle("hideable-target-show");  
  })
})
