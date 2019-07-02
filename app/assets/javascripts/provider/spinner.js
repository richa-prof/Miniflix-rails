$( document).on('turbolinks:load', function() {

  $(".spinner").hide();

  $(document).ajaxStart(function(){
    $(".spinner").show();
  });

  $(document).ajaxStop(function(){
    $(".spinner").hide();
  });

  $(document).ajaxError(function(){
    $(".spinner").hide();
  });
});

$(document).on("page:receive", function(){
  $(".spinner").hide();
});

$(document).on("page:fetch", function() {
  $(".spinner").show();
});