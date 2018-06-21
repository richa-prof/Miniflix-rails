// Reference: http://developmentmode.wordpress.com/2011/05/09/defining-custom-functions-on-jquery/
(function ($) {

  ajaxPaginationObjects = function() {
    return $('.ajaxPagination');
  };

  blogCommentsCountBtn = function() {
    return $('.blg-comm-count a');
  };

  blogSubscribeBtn = function() {
    return $('.blog-subscribe-btn');
  };

  bindClickEventOnBlogSubscribeBtn = function() {
    blogSubscribeBtn().click(function() {
      var blogSubscriberModalObj = $('#blogSubscriberModal');
      blogSubscriberModalObj.find('#blog_subscriber_email').val('');
      var errorContainer = blogSubscriberModalObj.find('.error-container');
      errorContainer.text('');
      blogSubscriberModalObj.modal('show');
    });
  };

  applyRemoteTrueToAjaxPaginationLinks = function() {
    ajaxPaginationObjects().find('.pagination a').attr('data-remote', 'true');
  };

  bindClickEventOnBlogCommentsCountBtn = function() {
    blogCommentsCountBtn().click(function() {
      $('html, body').animate({
          scrollTop: $(".comment-section").offset().top - 90
      }, 1000);
    });
  };

}) (jQuery);

var ready;

ready = function() {
  if (ajaxPaginationObjects().length) {
    applyRemoteTrueToAjaxPaginationLinks();
  }

  if (blogCommentsCountBtn().length) {
    bindClickEventOnBlogCommentsCountBtn();
  }

  if (blogSubscribeBtn().length) {
    bindClickEventOnBlogSubscribeBtn();
  }
};

$(document).ready(ready);
$(document).on('turbolinks:load', ready);
