//= require jquery
//= require jquery_ujs

$(document).ready(function() {
  $formatDateEls = $(".format-date");
  $.each($formatDateEls, function(key, value){
    var $el = value;
    var newDate = moment($el.innerText).format('L');
    $el.innerText = newDate;
  });
});