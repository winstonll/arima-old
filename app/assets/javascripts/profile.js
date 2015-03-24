$(document).ready(function() {
  $(".profile-questions-answered").click(function() {
    $(".profile-questions-toggle-answered").addClass("active");
    $(".profile-questions-toggle-asked").removeClass("active");

    $(".questions-asked").addClass("questions-hidden");
    $(".questions-answered").removeClass("questions-hidden");
  });

  $(".profile-questions-asked").click(function() {
    $(".profile-questions-toggle-asked").addClass("active");
    $(".profile-questions-toggle-answered").removeClass("active");

    $(".questions-answered").addClass("questions-hidden");
    $(".questions-asked").removeClass("questions-hidden");
  });
});
