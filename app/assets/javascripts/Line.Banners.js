var Line = window.Line || {};

/**
 * Varios Banners and CTA interactions
 */

Line.Banners = (function() {
  'use strict';
  var _bottomBannerTmplSel = '#template-bottombanner',
      _bottomBannerSel = '.banner-fixedbottom-2',
      _bottomBannerName = 'newuser-banner-fixedbottom',
      _displayedOnce = false,
      _targetMediums = [
        'facebook',
        'facebookpage',
        'HWPR',
        'paidsearch',
        'pla',
        'steelhouse',
        'yahoostyle',
        'yahoobeauty'
      ];

  // checks business rules to see if we should display banner
  // current rules:
  // * banner template exists in the document
  // * utm_medium is in specified array
  // * REMOVED: is not small width mode
  // alternate "new user" rules
  // * user class == unknown
  // * banner views < 1
  function _shouldDisplayBanner() {
    var matched = false,
        utm_medium = Line.Util.getQueryParamVal('utm_medium'),
        startBehavior = Line.Behavior.getData();

    if ($(_bottomBannerTmplSel).length) {
      if (utm_medium && ($.inArray(Line.Util.getQueryParamVal('utm_medium').toLowerCase(),_targetMediums) !== -1)) {
        matched = true;
      } else if (Line.User.getUserClass() === 'unknown') {
        // if we don't yet have a widget object, or if we do and it doesn't fit criteria
        if ((typeof startBehavior.widgets === 'undefined') || (typeof startBehavior.widgets[_bottomBannerName] === 'undefined')) {
          matched = true;
        } else if ((typeof startBehavior.widgets[_bottomBannerName].views === 'undefined') || (startBehavior.widgets[_bottomBannerName].views < 1)) {
          matched = true;
        }
      }
    }
    return matched;
  }

  function _displayBottomBanner() {
    // CLOSE GIFTS BANNER IF OPEN
    var topBanner = $('.pushdown-banner-content.tall');
    if (topBanner.length) {
      Line.PushdownBanner.toggle();
    }

    $(_bottomBannerSel).fadeIn({
      duration: Line.UI.ANIM_DURATION,
      easing: Line.UI.ANIM_EASING,
      complete: function() {
        Line.Track.event('bottom_banner','open',{'nonInteraction': 1});
        Line.Behavior.logWidgetInteraction(_bottomBannerName, 'views');
      }
    });
  }

  function _hideBottomBanner() {
   $(_bottomBannerSel).fadeOut({
      duration: Line.UI.ANIM_DURATION,
      easing: Line.UI.ANIM_EASING,
      complete: function() {
        $(_bottomBannerSel).remove();
        // NOTE: this event is recorded by 'x' at any step, and 'x' OR 'finish' at last step
        Line.Track.event('bottom_banner','close','Email Capture',1);
        Line.Behavior.logWidgetInteraction(_bottomBannerName, 'closed');
      }
    });
  }

  function _initBottomBanner() {
    var tmplHtml = Line.Util.safeTmplCompile(_bottomBannerTmplSel);

    if (tmplHtml.length) {
      // attach banner to DOM
      $('#bodyWrap').append(tmplHtml);
      $('.banner-fixedbottom-2').append('<div class="panel-mask"></div>');

      Line.Track.event('bottom_banner','load',{'nonInteraction': 1});

      // set up rules for display
      $(Line.e.SCROLLABLE_CONTAINERS).on(Line.e.CONTAINER_SCROLL_THROTTLE, function() {
        var top = Line.Containers.getContainerScrollTop();

        if (!_displayedOnce && top > 50) {
          _displayedOnce = true;
          _displayBottomBanner();
        }

      });

      // set up rules for hiding
      $(_bottomBannerSel).on('click','.remove,.btn-remove',function(e) {
        e.preventDefault();
        _hideBottomBanner();
      });

      // set up tracking for interactions
      $(_bottomBannerSel+' form').on('submit',function(e) {
        Line.Behavior.logWidgetInteraction(_bottomBannerName, 'engagement');
      });

    }
  }

  return {
    initialize: function() {
      // real code
      if (_shouldDisplayBanner()) {
        _initBottomBanner();
      }
    }
  };
}());
