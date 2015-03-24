// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
  $(".profile-questions-answered").click(function() {
    $(".questions-answered").css("display", "block");
    $(".questions-asked").css("display", "none");
  });

  $(".profile-questions-asked").click(function() {
    $(".questions-asked").css("display", "block");
    $(".questions-answered").css("display", "none");
  });
});
