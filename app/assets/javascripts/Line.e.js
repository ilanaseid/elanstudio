var Line = window.Line || {};

/**
 * Custom Event Handlers
 * Definition & initilization of event handling
 */

Line.e = (function() {
  'use strict';

  var mq_small,
      mq_smalltopnav,
      mq_print;

  // change body classes based on changes in media queries
  function _setMqWidth(mq) {
    if (mq.matches) {
      $('body').addClass('mq_small').removeClass('mq_notsmall');
    } else {
      $('body').addClass('mq_notsmall').removeClass('mq_small');
    }
    $(window).trigger(Line.e.MQ_WIDTH_CHANGE);
  }

  // change body classes based on changes in media queries
  function _setMqTopNav(mq) {
    if (mq.matches) {
      $('body').addClass('mq_smalltopnav').removeClass('mq_notsmalltopnav');
    } else {
      $('body').addClass('mq_notsmalltopnav').removeClass('mq_smalltopnav');
    }
  }

  // set throttle and debounce events for window interactions
  function _initializeWindowMonitors() {
    // test debounce/throttle for window events
    // note: this probably won't trigger in a nav2 world
    $(window).scroll($.throttle(200, function() {
      // console.log('window scroll throttle');
      $(window).trigger(Line.e.WINDOW_SCROLL_THROTTLE);
    }));
    $(window).scroll($.debounce(200, function() {
      // console.log('window scroll debounce');
      $(window).trigger(Line.e.WINDOW_SCROLL_DEBOUNCE);
    }));

    // additionally, watch our custom containers
    $(Line.e.SCROLLABLE_CONTAINERS).scroll($.throttle(200, function() {
      $(this).trigger(Line.e.CONTAINER_SCROLL_THROTTLE);
    }));
    $(Line.e.SCROLLABLE_CONTAINERS).scroll($.debounce(200, function() {
      $(this).trigger(Line.e.CONTAINER_SCROLL_THROTTLE);
    }));



    $(window).resize($.throttle(200, function() {
      // console.log('window resize throttle');
      $(window).trigger(Line.e.WINDOW_RESIZE_THROTTLE);
    }));
    $(window).resize($.debounce(200, function() {
      // console.log('window resize debounce');
      $(window).trigger(Line.e.WINDOW_RESIZE_DEBOUNCE);
    }));
  }

  // monitor for changes in media quieries
  function _initializeMediaQueryMonitors() {
    // manage mediaqueries
    if (window.matchMedia) {
      // column states
      mq_small = window.matchMedia('only screen and (max-width : 620px)');
      // matchMedia polyfill doesn't add listeners - avoid IE errors
      if (mq_small.addListener) {
        _setMqWidth(mq_small);

        mq_small.addListener(function(mq) {
          _setMqWidth(mq);
          $(window).trigger(Line.e.MQ_WIDTH_CHANGE);
        });
      }

      // top nav states
      mq_smalltopnav = window.matchMedia('only screen and (max-width: 800px)');
      // matchMedia polyfill doesn't add listeners - avoid IE errors
      if (mq_smalltopnav.addListener) {
        _setMqTopNav(mq_smalltopnav);
        mq_smalltopnav.addListener(function(mq) {
          _setMqTopNav(mq);
          $(window).trigger(Line.e.MQ_TOPNAV_CHANGE);
        });
      }

      // print or not
      mq_print = window.matchMedia('only print');
      if (mq_print.addListener) {
        mq_print.addListener(function(mq) {
          if (mq.matches) {
            Line.Track.eventOnce('print','open',document.location.href,1);
          }
        });
      }
    }
  }

  function _initializeFontEvents() {
    if( window.document.documentElement.className.indexOf( 'fonts-loaded' ) > -1 ){
      return;
    }

    var fontA,
        fontB,
        fontC,
        checkTime;

    checkTime = 10000;

    fontA = new FontFaceObserver( 'Sabon Next W01', {
      weight: 400
    });

    fontB = new FontFaceObserver( 'Sabon Next W01', {
      weight: 400,
      style: 'italic'
    });

    fontC = new FontFaceObserver( 'Sabon Next W01 Display', {
      weight: 300
    });

    window.Promise
      .all([fontA.check(null, checkTime), fontB.check(null, checkTime), fontC.check(null, checkTime)])
      .then(function(){
        $('html').addClass('fonts-loaded');
        Line.Behavior.setFeatureSupport('webfonts',true);
      });
  }

  return {
    SCROLLABLE_CONTAINERS: '#pageWrap',
    WINDOW_SCROLL_THROTTLE: 'window scroll throttle',
    WINDOW_SCROLL_DEBOUNCE: 'window scroll debounce',
    WINDOW_RESIZE_THROTTLE: 'window resize throttle',
    WINDOW_RESIZE_DEBOUNCE: 'window resize debounce',
    CONTAINER_SCROLL_THROTTLE: 'container scroll throttle',
    CONTAINER_SCROLL_DEBOUNCE: 'container scroll debounce',
    NAV_PANEL_OPEN: 'nav_panel_open',
    CART_PANEL_OPEN: 'cart_panel_open',
    PANEL_MASK_TRIGGERED: 'panel_mask_clicked',
    // HEADER_MENU_OPEN: 'navsubmenus_open', // match plugin events
    HEADER_PROVOCATION_TOGGLE: 'provocation_toggle',
    HEADER_SEARCH_TOGGLE: 'search_toggle',
    CONTEXTUAL_NAV_TOGGLE: 'contextual_nav_toggle',
    MQ_WIDTH_CHANGE: 'mq_width_change',
    MQ_TOPNAV_CHANGE: 'mq_topnav_change',

    initialize: function() {
      _initializeFontEvents();

      _initializeWindowMonitors();

      _initializeMediaQueryMonitors();

      // watch for manuaual scrolling - cancel any scroll animations
      // http://stackoverflow.com/questions/2834667/how-can-i-differentiate-a-manual-scroll-via-mousewheel-scrollbar-from-a-javasc
      $('body,html').bind('scroll mousedown wheel DOMMouseScroll mousewheel keyup', function(e){
       if ( e.which > 0 || e.type === 'mousedown' || e.type === 'mousewheel'){
        $('html,body').stop();
       }
      });
    }
  };
}());
