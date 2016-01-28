var Line = window.Line || {};

/**
 * Product Grid Functionality
 * includes both grid behaviors as well as product item interaction
 */

Line.ProductGrid = (function() {
  'use strict';

  var $masonryContainers,
      $quickshopContainer,
      minViewportForGrid = 521,
      masonryOpts = {
        // options
        columnWidth: '.grid-sizer',
        isResizeBound: true,
        itemSelector: '.item',
        transitionDuration: 0,
        gutter: '.gutter-sizer'
      },
      _isMasonryActive = false,
      _isQuickshopAnimating = false;

  // private functions

  // scrolls to a given element in the page
  function _scrollTo($elm,buffer) {
    var scrollToPos;

    buffer = (buffer) ? buffer : 0;

    // decide what position to scroll to
    // don't use scroll to elm if we're using masonry due to mixed positioning modes
    if (!_isMasonryActive) {
      Line.Containers.containerScrollToElm($elm, buffer);
    } else {
      // get itemGrid from document
      // get item from itemGrid
      // adjust by buffer
      scrollToPos = Line.Containers.getElementOffsetTop($elm.parents('.itemGrid')) + parseInt($elm.css('top'), 10) + buffer;
      Line.Containers.containerScrollToPos(scrollToPos);
    }
  }

  function _toggleQuickShop($item) {
    // var beforeH,
    //     afterH,
    //     diffH,
    //     itemL,
    //     $itemmeta,
    //     metaH,
    //     $afters;

    var closeY,
        openY,
        lastMetaH,
        nextMetaH,
        lastL,
        nextL,
        lastIndex,
        nextIndex,
        startIndex,
        $lastOpen,
        $nextOpen,
        $lastMeta,
        $nextMeta,
        $aftersLast,
        $aftersNext;
        // $aftersBoth,
        // $afters,
        // scrollToY;

    if (_isQuickshopAnimating) {
      Line.Track.event('quickshop', 'blocked', $item.attr('id'), 1);
      return;
    } else {
      _isQuickshopAnimating = true;
    }

    $lastOpen = $item.parents('.itemGrid').find('.item.active');
    $nextOpen = $item;
    Line.Track.event('quickshop', 'open', $nextOpen.attr('id'), 1);

    // CASE 1: if no last opened
    // CASE 2: if last opened left != next opened left
    // CASE 3: if last opened left == next opened left

    // grab the next objects
    $nextMeta = $nextOpen.find('.item-meta');
    nextMetaH = $nextMeta.height();
    nextL = $nextOpen.css('left');

    // determine movement styles
    openY = nextMetaH;

    if (!$lastOpen.length) {

      // make UI changes
      $nextOpen.addClass('active');

      // animate metas
      $nextMeta.css({
        height: 0,
        visibility: 'visible'
      }).animate(
        { height: openY },
        Line.UI.ANIM_DURATION,
        Line.UI.ANIM_EASING,
        function() {
          _isQuickshopAnimating = false;
        }
      );

      // STEP 5: move items that fall under it, without triggering masonry
      $aftersNext = $nextOpen.nextAll('.item');

      // This is totally dependant on masonry layout being tight
      $aftersNext.each(function(i) {
        if (nextL === $(this).css('left')) {
          $(this).animate(
            { top: parseInt($(this).css('top'), 10)+openY },
            Line.UI.ANIM_DURATION,
            Line.UI.ANIM_EASING
          );
        }
      });

      // only do this if we have a masonry grid.
      if (_isMasonryActive) {
        _scrollTo($nextOpen);
      }
    } else {
      // grab the last objects
      $lastMeta = $lastOpen.find('.item-meta');
      lastMetaH = $lastMeta.height();
      lastL = $lastOpen.css('left');

      // determine movement styles
      closeY = lastMetaH;

      // make UI changes
      $nextOpen.addClass('active');
      // $lastOpen.removeClass('active');

     // animate metas
      $nextMeta.css({
        height: 0,
        visibility: 'visible'
      }).animate(
        { height: openY },
        Line.UI.ANIM_DURATION,
        Line.UI.ANIM_EASING,
        function() {
          _isQuickshopAnimating = false;
        }
      );

      $lastMeta.animate(
        { height: 0 },
        Line.UI.ANIM_DURATION,
        Line.UI.ANIM_EASING,
        function() {
          $lastMeta.css({
            height: 'auto',
            visibility: 'hidden'
          });
          $lastOpen.removeClass('active');
        }
      );


      // STEP 5: move items that fall under it, without triggering masonry
      $aftersNext = $nextOpen.nextAll('.item');
      $aftersLast = $lastOpen.nextAll('.item');

      lastIndex = $lastOpen.index();
      nextIndex = $nextOpen.index();

      startIndex = (nextIndex < lastIndex) ? nextIndex: lastIndex;


      // IF things are in separate columns
      if (lastL !== nextL) {
        // open one column and close the other
        $item.parents('.itemGrid').find('.item').each(function(i) {
          if (i > lastIndex) {
            if (lastL === $(this).css('left')) {
              // up by lastMetaH
              $(this).animate(
                { top: parseInt($(this).css('top'), 10)-lastMetaH },
                Line.UI.ANIM_DURATION,
                Line.UI.ANIM_EASING
              );
            }
          }
          if (i > nextIndex) {
            if (nextL === $(this).css('left')) {
              // down by nextMetaH
              $(this).animate(
                { top: parseInt($(this).css('top'), 10)+nextMetaH },
                Line.UI.ANIM_DURATION,
                Line.UI.ANIM_EASING
              );
            }
          }
        });
        // only do this if we have a masonry grid.
        if (_isMasonryActive) {
          _scrollTo($nextOpen);
        }
      } else {
        if (nextIndex < lastIndex) {
          // only do this if we have a masonry grid.
          if (_isMasonryActive) {
            _scrollTo($nextOpen);
          }
        } else {
          // only do this if we have a masonry grid.
          if (_isMasonryActive) {
            _scrollTo($nextOpen,lastMetaH*-1);
          }
        }

        $item.parents('.itemGrid').find('.item').each(function(i) {
          // if item is below both

          // else if item is below just next
          // else if item is below just last

          if (i > lastIndex && i > nextIndex) {
            if (lastL === $(this).css('left')) {
              // move by difference in two
              $(this).animate(
                { top: parseInt($(this).css('top'), 10)-lastMetaH+nextMetaH },
                Line.UI.ANIM_DURATION,
                Line.UI.ANIM_EASING
              );
            }
          } else if (i > lastIndex) {
            if (lastL === $(this).css('left')) {
              // up by lastMetaH
              $(this).animate(
                { top: parseInt($(this).css('top'), 10)-lastMetaH },
                Line.UI.ANIM_DURATION,
                Line.UI.ANIM_EASING,
                function() {
                  // only do this to the final destination
                  if (i === nextIndex) {
                    // only do this if we have a masonry grid.
                    if (_isMasonryActive) {
                      _scrollTo($nextOpen);
                    }
                  }
                }
              );
            }
          } else if (i > nextIndex) {
            if (lastL === $(this).css('left')) {
              // down by nextMetaH
              $(this).animate(
                { top: parseInt($(this).css('top'), 10)+nextMetaH },
                Line.UI.ANIM_DURATION,
                Line.UI.ANIM_EASING
              );
            }

          }

        });

      }

    }

  }


  function _resize(e) {
    if ($masonryContainers.length) {
      if (window.innerWidth >= minViewportForGrid) {
        if (!_isMasonryActive) {
          $masonryContainers.masonry(masonryOpts);
          $masonryContainers.masonry();
          _isMasonryActive = true;
        }
      } else {
        if (_isMasonryActive) {
          $masonryContainers.masonry('destroy').data('masonry',null);
          _isMasonryActive = false;
        }
      }

    }
  }

  function _randomizeOrder(containers) {
    var checkTarget = $('body'), i, container, targetItems, targetList, outOfStockItems;

    if (checkTarget.hasClass('a_category') || checkTarget.hasClass('a_tag')) {
      for (i = 0; i < containers.length; i++) {
        container = containers.eq(i);
        targetList = container.find('ul.pl').eq(0);
        targetItems = container.find('.item:not(".status-new_product, .status-out_of_stock")');
        outOfStockItems = $('.status-out_of_stock');
        while(targetItems.length) {
          targetList.append(targetItems.splice(Math.floor(Math.random() * targetItems.length), 1)[0]);
        }
        targetList.append(outOfStockItems);
      }
    }

    return containers;
  }

  // public functions
  return {
    initialize: function() {
      var $quickshops;
          // CHANGE $masonryContainers TO SELECT $('.itemGrid') TO DISABLE
          $masonryContainers = _randomizeOrder($('.itemGrid'));
          $quickshopContainer = $('.quickshop').parents('.itemGrid');

      // STEP 1: initialize masonry grid behavior
      $masonryContainers.each(function() {
        var $this = $(this);

        $this.imagesLoaded(function() {
          if (window.innerWidth >= minViewportForGrid) {
            // if ($('#grid-widget').length) {
            //   Line.BookingWidget.setHeight();
            // }
            $this.masonry(masonryOpts);
            _isMasonryActive = true;
          }
        });

      });

      // STEP 2: initialize quick shop behavior for grids
      if ($quickshopContainer.length) {
        $quickshopContainer.each(function(){
          $quickshops = $quickshopContainer.find('.quickshop');

          $quickshopContainer.addClass('withQuickshopBuffer');

          // only if shoptype item / not simple related item
          $quickshops.find('.item-image a').on('tap',function(e) {
            var $this = $(this),
                $item = $this.parents('.item');

            // on first click open, on second click let the click happen
            if (!$item.is('.active')) {
              e.preventDefault();

              _toggleQuickShop($item);
            }
          });
        });
      }

      // STEP 3: watch resize events
      if ($masonryContainers.length) {
        $(window).on(Line.e.WINDOW_RESIZE_THROTTLE,_resize);
      }

    },

    isMasonryActive: function(){
      return _isMasonryActive;
    }
  };
}());
