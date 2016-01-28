var Line = window.Line || {};

/**
 * Manages interactions of search panel
 */

 Line.Search = (function() {
  'use strict';

  function _monitorExternalEvents() {
    // If provocation panel opens, close *any* open search panels
    $(window).on('provocation_toggle mq_topnav_change contextual_nav_toggle',function() {
      var $openSearchPanels = $('.searchPanel:visible');

      $openSearchPanels.slideUp({
        duration: Line.UI.ANIM_DURATION,
        easing: Line.UI.ANIM_EASING
      });
    });
  }

  return {

    initialize: function() {

      // watch for search window interaction
      $('body').on('click','.header-search-trigger',function(e) {
        var $trigger = $(this),
            $targetSearchPanel;

        // STEP 0: decide if we want to hijack interaction
        // NOTE: currently other options are removed in Line.NavPanels.js
        e.preventDefault();

        $(window).trigger('search_panel_toggle');

        // STEP 1: decide which panel we want to modify
        $targetSearchPanel = $trigger.parents('.hovernav').find('.searchPanel');

        // STEP 2: toggle visibily of panel
        $targetSearchPanel.slideToggle({
          duration: Line.UI.ANIM_DURATION,
          easing: Line.UI.ANIM_EASING,
          // STEP 3: set proper focus during interactions
          complete: function() {
            if ($(this).is(':visible')) {
              // NOTE: see if we can focus on iOS and not have the inteaction be so bad
              // $(this).find('input[type=search]').focus();
            } else {
              // NOTE: see if we can focus on iOS and not have the inteaction be so bad
              // $trigger.focus();
              Line.Track.event('search_panel','open','large top nav',1);
            }
          }
        });
      });

      _monitorExternalEvents();
    }
  };
}());

