// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready( function() {
  $(".category_select").on("change", function() {
    $.ajax({
      url: "/profile",
      type: "GET",
      dataType: "script",
      data: { category_type: $(".category_select").val() }
    });
  });
});