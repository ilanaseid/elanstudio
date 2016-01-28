var Line = window.Line || {};

/**
 * Manages creation and interactions and vislibily of nav panels
 */

 Line.NavPanels = (function() {
  'use strict';

  var $_bodyWrap,
      $_navPanelWrap,
      $_sourceNav,
      _i = 0;


  // loop through dom structure and label all nav triggers and their corresponding content lists
  // $tree is a .mainnav
  function _generatePanelIndexes($tree) {
    $tree.children('ul')
        .data('panel-index',0)
        .attr('id','panel-index-'+0);


    $tree.find('.nav-sub-trigger').each(function(){
      var parentPanelIndex = $(this).parents('ul').length ? $(this).parents('ul').eq(0).data('panel-index') : 0;

      _i++;
      $(this).children('a, .a').data('panel-target-index',_i);
      $(this).children('ul')
        .data('panel-index',_i)
        .attr('id','panel-index-'+_i)
        .data('parent-panel-index',parentPanelIndex);
    });
  }

  // loop through dom structure and title all panels
  // $tree is a .mainnav
  function _createTitles($tree) {
    // create title element
    $tree.find('ul').each(function() {
      if (typeof $(this).data('panel-title') !== 'undefined') {
        // don't do this for the top level right nav
        if (!$(this).parent().is('.mainnav-2')) {
          $(this).prepend('<li><span class="a nav-panel-title">'+$(this).data('panel-title')+'</span></li>');
        }
      }
    });
  }

  // loop through dom structure and create 'uplinks' for all panels
  // $tree is a .mainnav
  function _createUpButtons($tree) {
    $tree.find('ul').each(function() {
      var $currentList = $(this);

      $(this).parents('ul').each(function(){
        if (typeof $(this).data('panel-title') !== 'undefined') {
          $currentList.prepend('<li><button class="btn-link a icon_mobileNavLeft" data-target-panel-id="'+$(this).attr('id')+'-wrap">'+$(this).data('panel-title')+'</button></li>');
        }
      });
    });
  }

  function _convertNavStates($tree) {
    // convert item classes
    $tree.find('.sepWrap, .navPanelTriggerWrap, .desktopNavItem').remove();
    $tree.find('.icon_downCaret-ia').removeClass('icon_downCaret-ia').addClass('icon_mobileNavRight');
    $tree.find('.nav-sub-trigger').removeClass('nav-sub-trigger');
    $tree.find('.header-search-trigger').removeClass('header-search-trigger');
  }

  function _createNavPanels($oldLists, depth) {

    $oldLists.each(function() {
      var $thisPanel;

      // label
      $thisPanel = $('<div class="nav-panel nav-panel-'+depth+'"></div>');
      $thisPanel.attr('id',$(this).attr('id')+'-wrap');

      // finish and insert to dom
      $thisPanel.append($(this));
      $_navPanelWrap.append($thisPanel);
    });
  }

  function _buildNavPanels() {
    var $mainPanel,
        $tempSourceTree;

    $mainPanel = $('<div class="nav-panel nav-panel-1" id="panel-index-0-wrap"><ul id="panel-index-0"></ul></div>');


    // TOP LEFT
    // migrate full heirarchical menus from top left nav

    $tempSourceTree = $('.mainnav-1',$_sourceNav).clone();

    // create references for panels
    _generatePanelIndexes($tempSourceTree);
    _createTitles($tempSourceTree);
    _createUpButtons($tempSourceTree);
    _convertNavStates($tempSourceTree);
    _createNavPanels($tempSourceTree.find('ul ul ul'),3); // create 3rd level panels
    $tempSourceTree.find('ul ul ul').remove();
    _createNavPanels($tempSourceTree.find('ul ul'),2); // create 2nd level panels
    $tempSourceTree.find('ul ul').remove();

    $mainPanel.children('ul').append($tempSourceTree.find('li'));

    // $mainPanel.append($('.mainnav-1',$_sourceNav).clone());
    $mainPanel.addClass('nav-panel-open');


    // TOP RIGHT
    // migrate full heirarchical menus from top right nav
    $tempSourceTree = $('.mainnav-2',$_sourceNav).clone();

    // make this look like any other link
    $tempSourceTree.find('.siteMessageItem button')
        .addClass('icon_downCaret-ia')
        .parent().addClass('nav-sub-trigger')
        .find('#site-messaging').removeAttr('id'); // remove duplicate id

    // create references for panels
    _generatePanelIndexes($tempSourceTree);
    _createTitles($tempSourceTree);
    _createUpButtons($tempSourceTree);
    _convertNavStates($tempSourceTree);
    _createNavPanels($tempSourceTree.find('ul ul ul'),3); // create 3rd level panels
    $tempSourceTree.find('ul ul ul').remove();
    _createNavPanels($tempSourceTree.find('ul ul'),2); // create 2nd level panels
    $tempSourceTree.find('ul ul').remove();


    // massage some ordering things in nav
    $tempSourceTree.find('.siteMessageItem')
        .insertAfter($tempSourceTree.find('.siteMessageItem').siblings().last())
        .removeClass('siteMessageItem');

    $mainPanel.children('ul').append($tempSourceTree.find('li'));


    // finally, append to the container
    $_navPanelWrap.append($mainPanel);
  }

  function _transferInitialStates() {
    $('.nav-panel',$_navPanelWrap).each(function() {
      // transfer states
      if ($(this).find('.nav-header-current').length) {
        $(this).addClass('nav-panel-open');
      }
      if ($(this).find('.nav-sub-current').length) {
        $(this).addClass('nav-panel-childopen');
      }
    });
  }

  // put nav panels and containers in an open state and announce
  function _showNavPanels(e) {
    if (typeof e !== 'undefined') {
      e.preventDefault();
    }

    $_bodyWrap.addClass('nav-panels-open');
    $(window).trigger(Line.e.NAV_PANEL_OPEN);
  }

  // put nav panels and containers in a closed state
  function _hideNavPanels(e) {
    if (typeof e !== 'undefined') {
      e.preventDefault();
    }

    $_bodyWrap.removeClass('nav-panels-open');
  }


  function _monitorExternalEvents() {
    // on panel mask interaction, hide cart panels
    $(window).on(Line.e.PANEL_MASK_TRIGGERED, _hideNavPanels);
    // on resize (or mq change?) hide cart panels
    $(window).on(Line.e.WINDOW_RESIZE_DEBOUNCE, _hideNavPanels);
    // on cart panel open hide - probably never happen
    $(window).on(Line.e.CART_PANEL_OPEN, _hideNavPanels);
  }

  return {
    initialize: function() {
      $_bodyWrap = $('#bodyWrap');
      $_navPanelWrap = $('#navPanelWrap');
      $_sourceNav = $('#navWrap');

      // build nav panels
      _buildNavPanels();

      // set initial open states
      _transferInitialStates();

      $('.nav-panel-trigger').on('tap',_showNavPanels);
      $_navPanelWrap.on('swipeleft',_hideNavPanels);

      $('.icon_mobileNavRight',$_navPanelWrap).on('tap',function(e) {
        e.preventDefault();

        var $targetPanel = $('#panel-index-'+$(this).data('panel-target-index')+'-wrap',$_navPanelWrap);

        // clean up any old nav states before setting new ones
        if ($targetPanel.is('.nav-panel-2')) {
          // if i went all to the 2nd level
          $('.nav-panel-2',$_navPanelWrap).removeClass('nav-panel-open nav-panel-childopen');
        } else {
          // if i went all the way to the 3rd level
          $('.nav-panel-3',$_navPanelWrap).removeClass('nav-panel-open nav-panel-childopen');

        }

        // set linked panel to open,
        $targetPanel.removeClass('nav-panel-childopen').addClass('nav-panel-open');
        // set parent panel to childopen
        $(this).parents('.nav-panel').eq(0).addClass('nav-panel-childopen');
      });

      $('.icon_mobileNavLeft',$_navPanelWrap).on('tap',function(e) {
        e.preventDefault();

        var $targetPanel = $('#'+$(this).data('target-panel-id'),$_navPanelWrap);

        $targetPanel.removeClass('nav-panel-childopen');

        // clean up any intermediary steps in the chain - first with childopens
        if ($targetPanel.is('.nav-panel-1')) {
          $('.nav-panel-2',$_navPanelWrap).removeClass('nav-panel-childopen');
        }
      });

      // watch for external forces
      _monitorExternalEvents();

      $_navPanelWrap.removeClass('hide');
    }
  };
}());

