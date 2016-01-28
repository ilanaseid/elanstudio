var Line = window.Line || {};

// USAGE NOTES
// To use: Inside a <figure>, add a second picture element with class .rollover-image
// This second rollover <picture> will be hidden, but by including it in the DOM we can preload its images

// Example:
// <figure>
//  <picture>
//    * responsive picture goodness goes here *
//  </picture>
//  <picture class="rollover-image">
//    * responsive picture goodness goes here *
//  </picture>
//  <figcaption>maybe a caption, whatever</figcaption>
// </figure>

Line.RolloverImage = (function() {
  'use strict';

  function _initializeRolloverImages(){
    // first picture is in charge of enters and can toggle on click/tap
    $('.rollover-image').prev('picture').children('img').mouseenter(_enterRollover).click(_toggleRollover);  
    // .rollover-image itself is in charge of exits and can toggle on click/tap
    $('.rollover-image').children('img').mouseleave(_exitRollover).click(_toggleRollover); 
  }

  function _enterRollover(e) {
    var $parentPicture = $(e.target).parent('picture');
    $parentPicture.hide().next('picture.rollover-image').show();
  }

  function _exitRollover(e) {
    var $parentPicture = $(e.target).parent('picture.rollover-image');
    $parentPicture.hide().prev('picture').show();
  }

  function _toggleRollover(e){
    var $parentPicture = $(e.target).parent('picture');
    // stop the hover listeners now that click/tap registered
    $parentPicture.parent('figure').children('picture').children('img').off('mouseenter').off('mouseleave');
    
    if ($parentPicture.is('.rollover-image')) {
      $parentPicture.hide().prev('picture').show();
    } else {
      $parentPicture.hide().next('picture.rollover-image').show();
    }
  }

  return {
    initialize: function(){
      // only initialize if this page includes rollover images at load time
      if ($('.rollover-image').length > 0) {
        _initializeRolloverImages();
      }
    }
  };
}());
