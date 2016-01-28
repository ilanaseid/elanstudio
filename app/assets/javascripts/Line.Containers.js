var Line = window.Line || {};

/**
 * Manages state and behaviors of content containers & panels
 * handle sliding states, masking, etc
 */

 Line.Containers = (function() {
  'use strict';

  var $_bodyWrap = $('#bodyWrap'),
      $_viewWrap = $('#viewWrap'),
      _contextualNavScrollBuffer = 20;

  function _handleMaskClick(e) {
    e.preventDefault();

    $(window).trigger(Line.e.PANEL_MASK_TRIGGERED);
  }

  function _monitorExternalEvents() {
  }

  function _currentContainer() {
    return $('#pageWrap');
    // return ($('body').is('.mq_notsmalltopnav')) ? $('#viewWrap') : $('#pageWrap');
  }

  return {
    initialize: function() {
      _monitorExternalEvents();


      // create extra masks
      $_viewWrap.append('<div class="panel-mask"></div>');
      $_bodyWrap.append('<div class="panel-mask"></div>');

      $('.panel-mask').on('tap',_handleMaskClick);
    },

    // get offset top of element in relation to curent panel layout
    // TODO: test!
    getElementOffsetTop: function($elm) {
      var $currentContainer = _currentContainer();

      return $elm.offset().top + $currentContainer.scrollTop() - $currentContainer.offset().top;
    },

    getContainerScrollTop: function() {
      // if small, test pageWrap, otherwise test viewWrap
      return _currentContainer().scrollTop();
    },

    // scroll the current container to a given position
    containerScrollToPos: function(position) {
      var $currentContainer = _currentContainer();
      // augment position based on contextual nav
      position = position - $('#contextualNav').height() - _contextualNavScrollBuffer;

      $currentContainer.animate({
          scrollTop: position
        },
        Line.UI.ANIM_DURATION,
        Line.UI.ANIM_EASING
      );
    },

    // scroll the current container to an element
    containerScrollToElm: function($elm, buffer) {
      var position = 0;

      buffer = (buffer) ? buffer : 0;
      position = Line.Containers.getElementOffsetTop($elm) - buffer;

      Line.Containers.containerScrollToPos(position);
    }
  };
}());

