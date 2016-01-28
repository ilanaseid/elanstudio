var Line = window.Line || {};

/**
 * Manages creation and interactions and vislibily of cart panels
 */

 Line.CartPanels = (function() {
  'use strict';

  var $_bodyWrap,
      $_cartWrap;

  // put cart panels and containers in an open state and announce
  function _showCartPanels(e) {
    if (typeof e !== 'undefined') {
      e.preventDefault();
    }

    $_bodyWrap.addClass('cart-panel-open');
    $(window).trigger(Line.e.CART_PANEL_OPEN);
  }

  // put cart panels and containers in a closed state
  function _hideCartPanels(e) {
    if (typeof e !== 'undefined') {
      e.preventDefault();
    }

    $_bodyWrap.removeClass('cart-panel-open');
  }

  function _monitorExternalEvents() {
    // on panel mask interaction, hide cart panels
    $(window).on(Line.e.PANEL_MASK_TRIGGERED, _hideCartPanels);
    // on resize (or mq change?) hide cart panels
    $(window).on(Line.e.WINDOW_RESIZE_DEBOUNCE, _hideCartPanels);
    // on nav panel open hide - probably never happen
    $(window).on(Line.e.NAV_PANEL_OPEN, _hideCartPanels);
  }

  return {
    initialize: function() {
      $_bodyWrap = $('#bodyWrap');
      $_cartWrap = $('#cartWrap');


      // build cart panel / wrapper stuff (not panel contents)
      // NOTE: most of this specific content interaction and form handling JSON is in Line.Cart.js
      // handle click events, swipes, etc
      $('.cart-panel-trigger').on('tap',_showCartPanels);
      $_cartWrap.on('swiperight',_hideCartPanels);

      // watch for external forces
      _monitorExternalEvents();

      $_cartWrap.removeClass('hide');
    }
  };
}());

