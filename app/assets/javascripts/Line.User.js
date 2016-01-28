var Line = window.Line || {};

/**
 * User type, other data, and customization functions
 */

Line.User = (function() {
  'use strict';
  var _cookieName = 'behavior',
      _anonUserClass = 'unknown',
      _userClass = _anonUserClass;

  function _initUserClass() {
    var cookieData = $.cookie(_cookieName);

    // check that cookie was not set successfully:
    if (cookieData) {
      // then check cookie, if nothing found, set unknown
      if ((typeof cookieData.user_class === 'undefined') || (cookieData.user_class === null)) {
        _userClass = _anonUserClass;
      } else {
        _userClass = cookieData.user_class;
      }
    }

  }

  return {
    initialize: function() {
      // figure out current user type
      _initUserClass();

      // TODO: let google know

      // TODO: do any special inializations


    },
    getUserClass: function() {
      return _userClass;
    }
  };
}());
