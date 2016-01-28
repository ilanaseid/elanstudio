var Line = window.Line || {};

/**
 * Manages baseline top heiracical navigation behavior
 * Creates 3 interaction models
 * 1. CSS / .hovernav-nojs model
 * 2. JS initialized / .hovernav-js model
 * 3. JS + touch detected / .hovernav-js.hovernav-touchenabled model
 *
 * NOTE: it feels a little hacky, but some work here will be cloned
 * into the #contextualNav in Line.ContextualNav.js
 */

 Line.Nav = (function() {
  'use strict';

  return {
    initialize: function() {
      var $hovernav = $('.hovernav');

      // put is in the JS, but not yet touch enabled state
      $hovernav.removeClass('hovernav-nojs');


      // set up non-touch JS event tracking
      $hovernav
        .on('mouseover.notouch',function() {
          $(this).addClass('hovered');
        })
        .on('mouseout.notouch',function() {
          $(this).removeClass('hovered');
        });

      $('.nav-sub-trigger',$hovernav)
        .on('mouseover.notouch',function() {
          $(this).addClass('hovered');
          $(this).siblings('.nav-sub-trigger').removeClass('hovered');
        })
        .on('mouseout.notouch',function() {
          $(this).removeClass('hovered');
          $(this).siblings('.nav-sub-trigger').removeClass('hovered');
        });


      $('.nav-sub-trigger>a',$hovernav)
        .on('click.notouch',function(e) {
          // just let everything go
        });


      // set up touch JS event tracking
      $hovernav
        .on('touchstart.notouch',function() {
          var $thishn = $(this);

          $thishn.addClass('hovernav-touchenabled');

          // remove old events
          $thishn.off('.notouch');
          $('.nav-sub-trigger',$thishn).off('.notouch');
          $('.nav-sub-trigger>a',$thishn).off('.notouch');


          // rebuild events for a post touch world
          $thishn
            .on('mouseover.touch',function() {
              $(this).addClass('hovered');
            })
            .on('mouseout.touch',function() {
              // TBD: when do we remove the events? does this make any sense?
              $(this).removeClass('hovered');
            });

          $(Line.e.SCROLLABLE_CONTAINERS).on(Line.e.CONTAINER_SCROLL_THROTTLE, function() {
            $('.hovernav').removeClass('hovered');
            $('.hovernav').find('.hovered').removeClass('hovered');
          });


          $('.nav-sub-trigger>a',$thishn)
            .on('tap.touch',function(e) {

              if ($(this).parent().is('.hovered')) {
                // already hovered, let it through
                e.preventDefault();
                // $(this).trigger('click'); // get around ios being clever
                document.location.href = $(this).attr('href');
              } else {
                // remove hover state from siblings and all siblings children
                $(this).parent().siblings('.nav-sub-trigger').removeClass('hovered').find('.nav-sub-trigger').removeClass('hovered');
                // Q: what are "siblings" when you're at the top level?
                if ($(this).parent().parent().is('.nav-header-1')) {
                  // find all OTHER .nav-header-1 and remove all hovered states
                  $('.nav-header-1').not($(this).parent().parent()).find('.nav-sub-trigger').removeClass('hovered');
                }
                $(this).parents('.nav-sub-trigger').addClass('hovered');
                $(this).parents('.hovernav').addClass('hovered');
                e.preventDefault();
              }
            });
        });

      $hovernav.addClass('hovernav-js');

      // MOCK HOVER OVER OBJECTS LINK IN NAV
      $('ul[data-panel-title="The Objects"]').eq(2).addClass('nav-header-current');

    }
  };
}());

