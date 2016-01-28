var Line = window.Line || {};

/**
 * Runs Account management UI and widgets
 */

Line.Account = (function() {
  'use strict';

  var $_currentUnlockedPartial = null,
      _currentUnlockedContainer = null;

  function _revertCurrentPartialContainer(){
    if (_currentUnlockedContainer !== null) {
      $(_currentUnlockedContainer).html($_currentUnlockedPartial.html());
      $('.xhr-partial-trigger').show();

      _clearCurrentPartialContainer();
    }
  }

  // invalidate cache of partial
  function _clearCurrentPartialContainer() {
    $_currentUnlockedPartial = null;
    _currentUnlockedContainer = null;
  }

  function _submitAccountManagementForm(e, $form){
    // Account management page has 'locking' sections of partials and forms for each area
    var xhrResponseTarget = $form.data('xhr-partial-target'),
        url,
        formData;

    // check to see if we have the appropriate container to target on the page, if not:
    // a) we are in full-page view
    // or b) we screwed up
    // or c) user just has javascript disabled and this isn't running
    // in all those cases we can just let html form do a request for full page
    if ($(xhrResponseTarget).length > 0) {
      e.preventDefault();
      url = $form.attr('action'),
      formData = $form.serialize();

      $.post(url, formData, function(data) {
        // STEP 1: Update content area
        // STEP 2: Follow up with UI updates
        $(xhrResponseTarget).html(data);
        // do some cleanup if response is a closed state
        if (!$(xhrResponseTarget).find('form').length) {
          _clearCurrentPartialContainer();
        }
      });
    }
  }

  return {
    submitAccountManagementForm: function(e,$form) {
      _submitAccountManagementForm(e,$form);
    },

    initialize: function() {
      //quick check for perf
      if ($('body').is('.c_spree_users')) {

        // non-lightbox XHR behavior, replacing individual layout sections without a full-page reload
        $('body').on('click','.xhr-partial-trigger', function(e) {
          e.preventDefault();
          var $this = $(this),
              href = $this.attr('href'),
              xhrResponseTarget = $this.data('xhr-partial-target');

          $('.form-messages').remove(); // TODO: brute force we want to clear other flash messages around the page at this
          _revertCurrentPartialContainer(); // TODO: why are we doing this on the entry click? outdated cache can appeartime? - do before cloning nodes
          $_currentUnlockedPartial = $(xhrResponseTarget).clone();
          _currentUnlockedContainer = xhrResponseTarget;

          $.get(href, function(data) {
            $(xhrResponseTarget).html(data);
            Line.Track.pageView(href);
          });
        });

        // close locking xhr partial and revert to previous state
        $('body').on('click', '.xhr-close-partial-trigger', function(e) {
          e.preventDefault();
          $('.form-messages').remove(); // TODO: brute force we want to clear other flash messages around the page at this
          _revertCurrentPartialContainer();
        });
      }
    }
  };
}());
