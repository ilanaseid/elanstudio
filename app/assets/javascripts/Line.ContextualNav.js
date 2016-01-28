var Line = window.Line || {};

/**
 * Manages stickiness and behavior of contextual nav bar
 */

 Line.ContextualNav = (function() {
  'use strict';

  var _contextualNavId = 'contextualNav',
      $_contextualNav,
      $_sourceNav,
      _contextualNavTrigger = 240;

  function _buildContextualNav() {
    var $targetLeft,
        $targetRight,
        $tempMenuItems,
        $activeTopMenuItem,
        tmplHtml;

    tmplHtml = Line.Util.safeTmplCompile('#template-contextualNav');

    if (tmplHtml.length) {
      $_contextualNav
        .html(tmplHtml)
        .addClass('hovernav hovernav-nojs');
    } else {
      // BAIL EARLY
      return;
    }


    // construct top left contents
    $targetLeft = $_contextualNav.find('#mainnav-1-target');

    // CLONE EXISTING PARTS
    // 1. grab whole content nav - need a container node to manipulate the dom, not just an array of LIs
    $tempMenuItems = $('.mainnav-1>ul',$_sourceNav).clone(true);

    // 2. flatten out active structure (left side only)
    $activeTopMenuItem = $tempMenuItems.children('.nav-sub-current');
    if ($activeTopMenuItem.length) {
      $activeTopMenuItem.find('.nav-sub-current');
      $activeTopMenuItem.after($activeTopMenuItem.find('.nav-sub-current').clone(true));
    }

    // 3. rip out 2nd level from all navs / update carets & links & states
    $tempMenuItems.find('ul ul').siblings('a').removeClass('icon_downCaret-ia').off('tap').end().remove();
    $tempMenuItems.find('ul .nav-sub-trigger').children('a').off('click').end().removeClass('nav-sub-trigger');
    $tempMenuItems.find('.nav-header-current').removeClass('nav-header-current'); // don't have anything default to open

    // 4. remove mobile panel only items, insert panel reveals
    // $tempMenuItems.find('.mobileNavItem').remove();
    // $tempMenuItems.prepend($('.nav-panel-trigger').clone(true).wrap('<li class="mobileNavItem"></li>').parent());

    // 5. attach it all to the document
    $targetLeft.prepend($tempMenuItems.children());


    // construct top right contents
    $targetRight = $_contextualNav.find('#mainnav-2-target');
    $('.mainnav-2>.nav-header>li',$_sourceNav).clone(true).appendTo($targetRight);
    $targetRight.find('.nav-header-current').removeClass('nav-header-current'); // don't have anything default to open

    $_contextualNav.removeClass('hide');
  }

  function _duplicateSearchPanel() {
    $_contextualNav.append($('.searchPanel').clone());
  }

  function _showContextualNav() {
    if (!$_contextualNav.is('.'+_contextualNavId+'-stuck')) {
      $_contextualNav.addClass(_contextualNavId+'-stuck');
      $(window).trigger('contextual_nav_toggle');
    }
  }

  function _hideContextualNav() {
    if ($_contextualNav.is('.'+_contextualNavId+'-stuck')) {
      $_contextualNav.removeClass(_contextualNavId+'-stuck');
      $(window).trigger('contextual_nav_toggle');
    }
  }

  // handles visibily changes based on suer scroll behaviors
  function _handleScroll() {
    var top = Line.Containers.getContainerScrollTop();

    if (top > _contextualNavTrigger) {
      _showContextualNav();

    } else {
      _hideContextualNav();
    }
  }

  // influence anchor scrolling based on room needed to clear contextualNav
  function _adjustAnchorScroll() {
    var anchor = window.location.hash;

    if (anchor !== '' && $(anchor).length) {
      Line.Containers.containerScrollToElm($(anchor));
    }
  }

  // watch for external events that influence contextual nav state
  function _monitorExternalEvents() {
    // watch scroll for display toggle of sticky header
    $(Line.e.SCROLLABLE_CONTAINERS).on(Line.e.CONTAINER_SCROLL_THROTTLE, _handleScroll);

    // watch resize event for display toggle of sticky header
    $(window).on(Line.e.WINDOW_RESIZE_DEBOUNCE, _handleScroll);
  }

  return {
    initialize: function() {
      $_contextualNav = $('#'+_contextualNavId);
      $_sourceNav = $('#navWrap');

      _buildContextualNav();

      _duplicateSearchPanel();

      _monitorExternalEvents();

      // TODO: why does this need to wait for sp long? drawing stuffs? JS init stuff?
      window.setTimeout(_adjustAnchorScroll,800);
    }
  };
}());

