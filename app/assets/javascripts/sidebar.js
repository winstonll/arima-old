$(document).ready(function() {
  var $questionSidebar = $('#questions-sidebar');

  var currentWidth = function(){
    return (window.innerWidth > 0) ? window.innerWidth : screen.width;
  }

  var decideSidebarVisibility = function(event){
    if (currentWidth() > 850) {
      $questionSidebar.addClass('expanded');
      openSidebar();
    }else{
      $questionSidebar.removeClass('expanded');
      closeSidebar();
    }
  };

  decideSidebarVisibility(null);
  
  // Listen onResize to ensure sidebar is opened on wide screens
  window.onresize = decideSidebarVisibility

  // Trigger Menu expand/collapse
  $('#questions-menu').click(function(e) {
    toggleSidebar();
  });

  // Trigger menu close when categories title is clicked
  $('#sidebar-mobile-close-toggle').click(function(e) {
    toggleSidebar();
  });

  function toggleSidebar() {
    if ($questionSidebar.hasClass('expanded')) {
      closeSidebar();
      $questionSidebar.removeClass('expanded');
    } else {
      openSidebar();
      $questionSidebar.addClass('expanded');
    }
  }

  function openSidebar() {
    // Need to change body bg-color to mask sidebar animation entry
    $('body').css('background-color', '#404141');

    // css the sidebar in by increasing its left margin to 0
    $questionSidebar.css({
      "margin-left": "0%",
    });

    // Push the content to make way for the sidebar
    $('.site-content').css({
      "left": $questionSidebar.width()
    });
  }

  function closeSidebar() {
    $('body').css('background-color', '#fff');

    $questionSidebar.css({
      "margin-left": "-100%",
    });

    $('.site-content').css({
      "left": 0
    });
  }

  //Initialize scrolling
  $('.tse-scrollable').TrackpadScrollEmulator();

  //Highlights the current category
  $(function(){
     $(".sidebar-category").each(function(){
       if (window.location.href.indexOf($(this).attr("href")) != -1) {
          $(this).find(".category-inner-container").addClass("category-inner-container-active");
          $(this).find(".category-title").css({"font-weight": "bold"});  
       }
     });
  });
});
