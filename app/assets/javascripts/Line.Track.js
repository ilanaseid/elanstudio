var Line = window.Line || {};

/**
 * Abstracts user tracking through google analytics or other API
 */

Line.Track = (function() {
  'use strict';

  var _trackOnceCache = [];

  // places a unique ID on links without existing ID
  function _tagAllLinks() {
    $('a').not('[id]').map(function() {
      var $this = $(this),
          $closest;

      $closest = $this.closest('[id]');
      $this.attr('id',$closest.attr('id')+'_link'+$closest.find('a').index($this));
    });
  }

  function _googleEvent(category, action, label, value) {
    if (typeof ga !== 'undefined') {
      ga('send','event', category, action, label, value);
    }
  }

  function _googlePage(href) {
    if (typeof ga !== 'undefined') {
      ga('send','pageview', href);
    }
  }

  function _googleSocial(network,action,target) {
    if (typeof ga !== 'undefined') {
      ga('send','social', network, action, target);
    }
  }

  function _heapEvent(eventName,options) {
    if (typeof heap !== 'undefined') {
      heap.track(eventName, options);
    }
  }

  function _heapIdentify(userOptions) {
    if (typeof heap !== 'undefined') {
      heap.identify(userOptions);
    }
  }

  function _addConversionPixel(pixelUrl) {
    var $img = $('<span class="trackingpixel"></span>');
    $img.css('background-image','url('+pixelUrl+')');
    $img.appendTo('body');
  }

  // public functions
  return {
    initialize: function() {
      _tagAllLinks();

      $('.alert-track').each(function(){
        _googleEvent('systems','flash_message',$(this).text());
      });
      $('.translation_missing').each(function(){
        _googleEvent('systems','translation_missing',$(this).attr('title'));
      });
      $('.pagination_prefs a').on('click',function(){
        _googleEvent('pagination','click',$(this).text());
      });
    },

    // track outbound link clicks
    outbound: function(href) {
     _googleEvent('outbound','click',href,1);
    },

    // track mailto: link clicks
    mailto: function(href) {
      _googleEvent('mailto','click',href,1);
    },

    // track custom event
    event: function(category, action, label, value) {
      // Default (DRYest) way of tracking most custom events.  Sends to GA and Heap in one method.
      _googleEvent(category, action, label, value);
      _heapEvent((category + '-' + action), {label: value});
    },

    // track custom event
    eventOnce: function(category, action, label, value) {
      // Default (DRYest) way of tracking one-time custom events. Sends to GA and Heap in one method.
      if (typeof _trackOnceCache[category+action+label+''] === 'undefined') {
        _trackOnceCache[category+action+label+''] = true;
        _googleEvent(category, action, label, value);
        _heapEvent((category + '-' + action), {label: value});
      }
    },

    // Track Event in Heap Only
    heapEvent: function(eventName, options) {
      // for use in custom events where a seperate GA API call has already been made or is unneccesary
      // ex: mapping GA Conversions to Heap in order_tracking, or matching ga('set') of custom dimensions.
      _heapEvent(eventName, options);
    },

    // set Heap user identity by unique email
    identify: function(options) {
      // labels a visitor for per-user tracking with a JSON hash.
      _heapIdentify(options);
    },

    // track social interactions
    social: function(network, action, target, href) {
      _googleSocial(network,action,target);
      // temporarily double track, to conform reports
      _googleEvent('outbound','click',href,1);
    },

    // track any request as a page view
    pageView: function(href) {
      _googlePage(href);
    },

    // track a generic "conversion"
    conversion: function(pixelUrls) {
      var bust = Date.now();
      if (typeof pixelUrls === 'string') {
        _addConversionPixel(pixelUrls.replace('__bust__',bust));
      } else if (typeof pixelUrls === 'object') {
        $.each(pixelUrls,function() {
          _addConversionPixel(this.replace('__bust__',bust));
        });
      }
    }
  };
}());

