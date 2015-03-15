// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready( function() {
  $(".filter-location-select").on("change", function() {
    $.ajax({
      url: "/leaderboard",
      type: "GET",
      dataType: "script",
      data: { country_type: $("#country-filter").val() }
    });
  });
});
