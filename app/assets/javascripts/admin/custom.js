// Reference: http://developmentmode.wordpress.com/2011/05/09/defining-custom-functions-on-jquery/
(function ($) {

  adminMainSidebar = function() {
    return $('aside.main-sidebar');
  };

  contentWrapper = function() {
    return $('.content-wrapper');
  };

  setMinHeightOfContentWrapper = function() {
    var sidebarHeight = adminMainSidebar().css('height');
    contentWrapper().css('min-height', sidebarHeight);
  };

}) (jQuery);

var ready;

ready = function() {
  console.log('>>>>> invoked `ready` function of `admin/cutsom.js` >>>>>');

  if (adminMainSidebar().length) {
    setMinHeightOfContentWrapper();
  }
};

$(document).ready(ready);
$(document).on('turbolinks:load', ready);
