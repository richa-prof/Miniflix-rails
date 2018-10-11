// Reference: http://developmentmode.wordpress.com/2011/05/09/defining-custom-functions-on-jquery/
(function ($) {
  bindClickEventOnApiListTableRows = function() {
    $("#apiList tr.odd").off('click').on('click', function(event) {
      var display = $(this).next("tr").css('display');
      $("#apiList > tbody > tr:not(.odd)").hide();
      $("#apiList > tbody > tr:first-child").show();
      if (display == "none") {
          $(this).next("tr").css('display', 'table-row');
          $(this).find(".arrow").toggleClass("up");
      }
      else {
          $(this).next("tr").css('display', 'none');
          $(this).find(".arrow").toggleClass("up");
      }
    })
  };
}) (jQuery);

var ready;

ready = function() {
  $("#apiList > tbody > tr:odd").addClass("odd");
  $("#apiList > tbody > tr:not(.odd)").hide();
  $("#apiList > tbody > tr:first-child").show();

  bindClickEventOnApiListTableRows();
};

$(document).ready(ready);
// $(document).on('turbolinks:load', ready);
