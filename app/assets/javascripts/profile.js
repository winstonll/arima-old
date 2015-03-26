$(document).ready(function() {
  $(".profile-questions-answered").click(function() {
    $(".profile-questions-toggle-answered").addClass("active").css({"border-color": "#639ee3", "border-width": "2px", "border-style": "solid"});
    $(".profile-questions-toggle-asked").removeClass("active").css({"border-color": "#9B9A9C", "border-width": "2px", "border-style": "solid"});

    $(".questions-asked").addClass("questions-hidden");
    $(".questions-answered").removeClass("questions-hidden");
  });

  $(".profile-questions-asked").click(function() {
    $(".profile-questions-toggle-asked").addClass("active").css({"border-color": "#639ee3", "border-width": "2px", "border-style": "solid"});
    $(".profile-questions-toggle-answered").removeClass("active").css({"border-color": "#9B9A9C", "border-width": "2px", "border-style": "solid"});

    $(".questions-answered").addClass("questions-hidden");
    $(".questions-asked").removeClass("questions-hidden");
  });
});
