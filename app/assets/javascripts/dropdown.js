document.querySelectorAll(".dropdown-toggle").forEach(function(e) {
  e.addEventListener("click", function(e) {
    e.preventDefault();
    e.target.closest(".dropdown").classList.toggle("open");
  })
})
