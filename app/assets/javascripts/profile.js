// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
  $(".profile-questions-answered").click(function() {
    $(".profile-questions-toggle-answered").addClass("active");
    $(".profile-questions-toggle-asked").removeClass("active");
    $(".questions-answered").css("display", "block");
    $(".questions-asked").css("display", "none");
    // $(".questions-asked").addClass("questions-hidden");
    // $(".questions-answered").removeClass("questions-hidden");
  });

  $(".profile-questions-asked").click(function() {
    $(".profile-questions-toggle-asked").addClass("active");
    $(".profile-questions-toggle-answered").removeClass("active");
    $(".questions-asked").css("display", "block");
    $(".questions-answered").css("display", "none");
    // $(".questions-answered").addClass("questions-hidden");
    // $(".questions-asked").removeClass("questions-hidden");
  });
});
