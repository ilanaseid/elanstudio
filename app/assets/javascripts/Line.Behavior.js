var Line = window.Line || {};

/**
 * Manage User Behavior Logging
 *    Cookie JSON structure
 *    behavior : {
 *     'user_class' : string val,
 *     'visits' : int val,
 *     'views' : int val,
 *     'features' : [
 *        'feature_id' : boolean val
 *     ],
 *     'widgets' : [
 *       'widget_id' : {
 *         views: int val,
 *         closed: int val,
 *         engagements: int val
 *       }
 *     ]
 *   }
 */

Line.Behavior = (function() {
  'use strict';
  var _cookieName = 'behavior',
      _jsonData = null,
      _defaultJsonData = {
        user_class: null,
        visits: 0,
        views: 0,
        widgets: {}
      };

  function _readCookie() {
    _jsonData = $.cookie(_cookieName);
    if (_jsonData === null || typeof _jsonData !== 'object') {
      $.removeCookie(_cookieName, { path: '/' }); // TBD: is this too dangerous?
      _jsonData = _defaultJsonData;
    }
    return $.cookie(_jsonData);
  }

  function _saveCookie() {
    $.cookie(_cookieName, _jsonData, { expires: 999, path: '/' });
    return true;
  }

  return {
    initialize: function() {
      // read cookie data
      _readCookie();

      // log a page view
      this.logView();
    },
    getData: function() {
      return _jsonData;
    },
    getWidgetData: function() {

    },
    logView: function() {
      if (typeof _jsonData.views === 'number') {
        _jsonData.views++;
      } else {
        _jsonData.views = 1;

      }
      _saveCookie();
      return _jsonData.views;
    },
    logVisit: function() {
      if (typeof _jsonData.visits === 'number') {
        _jsonData.visits++;
      } else {
        _jsonData.visits = 1;

      }
      _saveCookie();
      return _jsonData.visits;
    },
    setFeatureSupport: function(feature,supported) {
      if (typeof _jsonData.features === 'undefined') {
        _jsonData.features = {};
      }

      _jsonData.features[feature] = supported;
      _saveCookie();
      return _jsonData.features[feature];
    },
    logWidgetInteraction: function(widget,type) {
      if (typeof _jsonData.widgets === 'undefined') {
        _jsonData.widgets = {};
      }

      if (typeof _jsonData.widgets[widget] === 'undefined') {
        _jsonData.widgets[widget] = {
          'views': 0,
          'closed': 0,
          'engagements': 0
        };
        _jsonData.widgets[widget][type] = 1;
      } else {
        _jsonData.widgets[widget][type]++;
      }
      _saveCookie();
      return _jsonData.widgets[widget];
    }
  };
}());
