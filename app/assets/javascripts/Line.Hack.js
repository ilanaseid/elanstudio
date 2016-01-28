var Line = window.Line || {};
/**
 * Manages ipad ios8 bugs and other hacks
 */

Line.Hack = (function() {
  'use strict';
  
  // hack to fix ipad webkit-overlfow-scrolling issues on ipad ios8
  function _toggleMomentumScrolling(){
    $('#pageWrap').css('-webkit-overflow-scrolling','auto');

    setTimeout(function() {
      $('#pageWrap').css('-webkit-overflow-scrolling','touch');
    },500);
  }

  return {
    initialize: function() {

      // MOMENTUM SCROLLING FOR IPADS
      if ($('.itemGrid').length) {
        setTimeout(function() {
          _toggleMomentumScrolling();
        }, 500);
      }

    }
  };

}());

