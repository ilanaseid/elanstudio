var Line = window.Line || {};

Line.PushdownBanner = (function() {

  'use strict';

  function _checkAndLaunch() {
    var banner = $('.pushdown-banner-header');
    if (banner.length) {
      _displayBanner(banner);
    }
  }

  function _displayBanner(bannerEl) {
    // HIDING CONTEXUAL NAV UNTIL BANNER LOADS
    var contextualNav = $('#contextualNav');
    contextualNav.css({'top': '38px'});
    contextualNav.hide();

    // LOAD FIXED BANNER
    $(window).load(function() {
      var bodyWrap = $('#bodyWrap');

      bodyWrap.animate({'padding-top': '38px'}, Line.UI.ANIM_DURATION, Line.UI.ANIM_EASING);
      bannerEl.slideDown({
        duration: Line.UI.ANIM_DURATION,
        easing: Line.UI.ANIM_EASING,
        complete: function() {
          var userData = Line.Behavior.getData();
          // FIX FOR CART POSITION
          $('#cartWrap').attr('style', 'padding-top: 38px !important;');
          // RECOVER CONTEXTUAL NAV
          contextualNav.show();
          if (userData.visits === 1 && userData.views === 1) {
            _toggleBanner();
          }
        }
      });
    });

    // EVENTS
    $(document).on('click tap', '.pushdown-banner-header', _toggleBanner);
    $(document).on('click tap', '.close-button', _toggleBanner);
    $(document).on('click', '#link-to-gifts', _trackAction);
  }

  function _toggleBanner(e) {
    
    var shortBanner = $('.pushdown-banner-header'),
        tallBanner = $('.pushdown-banner-content');

    if (!tallBanner.hasClass('tall')) {
      $('#bodyWrap').animate({'padding-top': '100px'}, 300, Line.UI.ANIM_EASING);
      tallBanner.animate({height: '100px'}, 300, Line.UI.ANIM_EASING, function() {
        $('#contextualNav').css({'top': '100px'});
        $('#cartWrap').attr('style', 'padding-top: 100px !important;');
        shortBanner.toggle();
        tallBanner.addClass('tall');
      });
      if (typeof(e) === 'undefined') {
        Line.Track.event('gifts_banner','open', 'holiday', {'nonInteraction': 1});
      } else {
        Line.Track.event('gifts_banner', 'open', 'holiday', 1);
      }
    } else {
      $('#bodyWrap').animate({'padding-top': '38px'}, 300, Line.UI.ANIM_EASING);
      shortBanner.toggle();
      $('#contextualNav').css({'top': '38px'});
      $('#cartWrap').attr('style', 'padding-top: 38px !important;');
      tallBanner.animate({height: '0px'}, 300, Line.UI.ANIM_EASING, function() {
        tallBanner.removeClass('tall');
      });
      Line.Track.event('gifts_banner', 'close', 'holiday', 1);
    }

  }

  function _trackAction(e) {
    Line.Track.event('gifts_banner', 'continued_to_gifts', 'holiday', 1);
  }

  return {
    initialize: function() {
      _checkAndLaunch();
    },
    toggle: function() {
      _toggleBanner();
    }
  };

}());
