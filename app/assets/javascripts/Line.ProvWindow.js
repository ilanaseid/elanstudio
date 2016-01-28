var Line = window.Line || {};

/**
 * Manages interactions of provication window
 */

 Line.ProvWindow = (function() {
  'use strict';

  function _monitorExternalEvents() {
    // watch for other events that force a provWindow close;
    $(window).on('search_panel_toggle contextual_nav_toggle',function() {
      var $openProvWindows = $('.provWindow:visible');

      $openProvWindows.slideUp({
        duration: Line.UI.ANIM_DURATION,
        easing: Line.UI.ANIM_EASING,
        complete: function() {
          $('.header-prov-trigger').removeClass('active');
        }
      });
    });
  }

  return {

    initialize: function() {

      // watch for provocation interaction
      $('.header-prov-trigger, .provWindow').on('click',function(e) {
          var navstate = 'small top nav';

          // don't prevent clicks on other links
          if ($(this).is('.header-prov-trigger')) {
            e.preventDefault();
          }

          $(window).trigger('provocation_toggle');

          $('.header-prov-trigger').toggleClass('active');

          // click event on the up and down caret for the quintessential header
          if ($(this).is('.header-prov-trigger')) {
            $(this).map(function() {
              var $this = $(this);
              // if active - insert upcaret, if closed, down caret
              if ($this.hasClass('active')) {
                $this.removeClass('icon_downCaret-ia').addClass('icon_upCaret-ia');
              } else {
                $this.removeClass('icon_upCaret-ia').addClass('icon_downCaret-ia');
              }
            });
          }

          // track opens
          if ($('.header-prov-trigger').is('.active')) {
            if ($('body').is('.mq_notsmalltopnav')) {
              navstate = 'large top nav';
            } else {
              navstate = 'small top nav';
            }
            Line.Track.event('provocation','open',navstate,1);
          }

          $('.provWindow').slideToggle({
            duration: Line.UI.ANIM_DURATION,
            easing: Line.UI.ANIM_EASING
          });
      });

      _monitorExternalEvents();
    }
  };
}());

