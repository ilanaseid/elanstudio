var Line = window.Line || {};

Line.FixedBanner = (function() {

  'use strict';

  var bannerTimer;

  function _checkRequirements() {
    var bannerEl = $('#top-banner-overlay');
    if (bannerEl.length) { _displayTopBanner(bannerEl); }
  }

  function _displayTopBanner(bannerEl) {
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
          // FIX FOR CART POSITION
          $('#cartWrap').attr('style', 'padding-top: 38px !important;');
          // FIX BUTTON COPY
          $('#top-banner-content').find('.btn').val('Sign up');
          $('#top-banner').toggle();
          contextualNav.show();
        }
      });
      // TRIGGER LOGIC
      if (Line.User.getUserClass() === 'unknown' && Line.Behavior.getData().visits === 1 && userData.views === 1) {
        bannerTimer = setTimeout(function() {
          _toggleTopBanner();
        }, 3000);
      }
    });

    // EVENTS
    $(document).on('click', '#top-banner-overlay', _toggleTopBanner);
    $(document).on('click', '#close-top-banner', _toggleTopBanner);
    $(document).on('click', '.triggerTopModal', _toggleTopBanner);
  }

  function _toggleTopBanner(e) {
    e.preventDefault();
    clearTimeout(bannerTimer);
    var banner = $('#top-banner');
    if (banner.hasClass('short')) {
      banner.removeClass('short').addClass('tall');
      $('#close-icon').removeClass('icon_downCaret-white-ia').addClass('icon_upCaret-white-ia');
      banner.animate({'height': '100%'}, 300, function() {
        $('#top-banner-content').slideDown({
          duration: Line.UI.ANIM_DURATION,
          easing: Line.UI.ANIM_EASING,
          complete: function() {
            // ADJUST MODAL CONTENT POSITION WITHIN MODAL WRAP
            var viewHeight = $(window).height() - 38;
            if (viewHeight < ($('#top-banner-main-content').height() + 35)) {
              $('#top-banner-content').css({'height': (contentHeight + 100) + 'px'});
            }
            Line.Track.event('la_banner','open',{'nonInteraction': 1});
          }
        });
      });
    } else {
      banner.removeClass('tall').addClass('short');
      $('#close-icon').removeClass('icon_upCaret-white-ia').addClass('icon_downCaret-white-ia');
      banner.animate({'height': '38px'}, 300, function() {
        $('#top-banner-content').toggle();
      });
    }
  }

  function _renderThankyou() {
    $('#top-banner-main-content').hide();
    $('#top-banner-thankyou').show();
    var viewHeight = $(window).height() - 38;
    if (($('#top-banner-thankyou').height() + 35) < viewHeight) {
      $('#top-banner-content').css({'height': viewHeight + 'px'});
    }
    window.scrollBy(0,0);
    Line.Track.event('la_banner','submit', 1);
    setTimeout(function() {
      _toggleTopBanner();
    }, 3000);
  }

  return {
    initialize: function() {
      _checkRequirements();
    },
    postFormSubmittion: function() {
      _renderThankyou();
    }
  };

}());
