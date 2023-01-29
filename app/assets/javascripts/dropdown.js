document.querySelectorAll(".dropdown-toggle").forEach(function(e) {
  e.addEventListener("click", function(e) {
    e.preventDefault();
    console.log("Clicked");
    console.log(e.target.parentElement);
    // TODO: Should really check that parent has dropdown class as we would expect
    e.target.parentElement.classList.toggle("open");
  })
})
