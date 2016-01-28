var Line = window.Line || {};

Line.WideLoaded = (function() {
  'use strict';

  var _selector = '.wideload';

  function _loadMarkup($elm) {
    var tmplSel = '#'+$elm.data('wideload-template');

    $elm.html(Line.Util.safeTmplCompile(tmplSel));
  }

  function _showElements($elms) {
    $elms.each(function showElementsEach() {
      if ($(this).data('wideloaded') === false) {
        // load data from template
        _loadMarkup($(this));

        $(this)
            // set state so we don't rebuild
            .data('wideloaded','true')
            // then show
            .show();
      } else {
        // just show
        $(this).show();
      }
    });
  }

  function _hideElements($elms) {
    $elms.hide();
  }

  function _test() {
    if ($('body').is('.mq_notsmall')) {
      _showElements($(_selector));
    } else {
      _hideElements($(_selector));
    }
  }

  function _monitorExternalEvents() {
    $(window).on(Line.e.WINDOW_RESIZE_DEBOUNCE, _test);
  }

  return {
    initialize: function() {
      _test();
      _monitorExternalEvents();
    }
  };
}());
