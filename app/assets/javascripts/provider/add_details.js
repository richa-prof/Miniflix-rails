$(document).on('ready turbolinks:load', function() {

  // var targetPages = ['/provider/movies/edit', '/provider/serials/edit', '/provider/movies/add_details', '/provider/serials/add_details'];
  // var basePath1 = window.location.pathname.split('/').slice(0,4).join('/');
  // var bp2 = window.location.pathname.split('/');
  // bp2.splice(3,1);
  // basePath2 = bp2.join('/');

  // console.log(basePath1, basePath2);
 
  //if ((targetPages.indexOf(basePath2) < 0 && targetPages.indexOf(basePath1) < 0) || $('body').data('mfx-edit-video')) {
  if ($('body').data('mfx-add-details-video')) {  
    console.warn("skip add_details js code init for page", window.location.pathname);
    return;
  }
  $('body').data('mfx-add-details-video', true); 

  //$('.datepicker').datepicker({format: ' yyyy', viewMode: "years", minViewMode: "years"});


});