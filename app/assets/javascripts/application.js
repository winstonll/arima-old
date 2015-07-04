// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs

//= require lib/bootstrap.min
//= require lib/underscore

//= require c3
//= require d3.v3
//= require prettySocial.min
//= require underscore
//= require gmaps/google
//= require typeahead
//= require jquery.trackpad-scroll-emulator.min

//= require users
//= require profile
//= require sidebar

$(document).ready(function() {

  // Navbar dropdown activation
  $(".dropdown").on("click", function(e) {
    if ($(".dropdown .menu").css("display") == "none") {
      $(".dropdown .menu").css("display", "block");
      return false;
    } else {
      $(".dropdown .menu").css("display", "none");
    }
  });

  $("body").on("click", function(e) {
    if ($(e.target).closest('.dropdown').length === 0) {
      if ($(".dropdown .menu").css("display") == "block") {
        $(".dropdown .menu").css("display", "none");
      }
    }
  });

  // stats/rank toggle button actions
  $("body").on("click", ".toggle-switches .btn", function(e){
    $target = $(e.target);
    $wrapper = $target.closest(".toggable-wrapper");

    // switch button styles
    $wrapper.find(".btn").removeClass("btn-primary").addClass("btn-default");
    $target.removeClass("btn-default").addClass("btn-primary");
    // hide all
    $wrapper.find(".toggable").addClass("hidden");

    // debugger;
    if ($target.hasClass("stats")) {
      // show stats
      $wrapper.find(".stats-panel").removeClass("hidden");
    }
    if ($target.hasClass("rank")) {
      // show rank
      $wrapper.find(".rank-panel").removeClass("hidden");
    }
  });

  // toggle most popular and most recent buttons
  $(".most-popular").click(function() {
    $(this).addClass("active");
  });

});

// Fade out alert messages
window.setTimeout(function() {
  $(".alert").fadeTo(500, 0).slideUp(500, function(){
    $(this).remove();
  });
}, 3000);
