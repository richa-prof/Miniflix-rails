// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


$(document).ready(function() {
  //data table for index page
  $('#tbl_movie_caption').DataTable();

  //check box for default caption
  $(".default_caption").change(function() {
    if(this.checked) {
      message = confirm("Make this caption default other default will be overwrite. Are you sure to make this file as default caption file for video ?");
      if(!message) {
         $(this).prop("checked", false)
      }
    }
  });

});

