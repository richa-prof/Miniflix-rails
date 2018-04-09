// Reference: http://developmentmode.wordpress.com/2011/05/09/defining-custom-functions-on-jquery/
(function ($) {

  fileFields = function() {
    return $(".uploadfile-field .form-control");
  };

  bindChangeEventOnFileFields = function() {
    fileFields().change(function(){
      var fileFieldVal = $(this).val().replace(/C:\\fakepath\\/i, '');
      var targetField = $(this).closest(".upload-file-all").find(".targetFileField");
      targetField.val(fileFieldVal);
    })
  };

}) (jQuery);

var ready;

ready = function() {
  if (fileFields().length) {
    bindChangeEventOnFileFields();
  }
};

$(document).ready(ready);
$(document).on('turbolinks:load', ready);
