var Line = window.Line || {};

Line.ShowMore = (function() {
  'use strict';

  var showMoreTriggers = $('.show-more-trigger');

  function _setupShowMoreTriggers(){
    showMoreTriggers.each(function(){
      $(this).on('click', _showMore);
    });
  }

  function _trackShowMore(label){
    Line.Track.event('show_all', 'click', label);
  }

  function _showMore(e){
    var $trigger = $(e.target),
        showMoreTargetStr = $trigger.data('show-more-target'),
        $showMoreTarget = $(showMoreTargetStr),
        $showMoreTargetList = $(showMoreTargetStr + ' ul.pl'),
        $showMoreData = $($.parseHTML($($trigger.data('show-more-data-src')).html()));

    $trigger.prop('disabled', true);

    $showMoreData.imagesLoaded(function() {
      $showMoreTargetList.append($showMoreData);
      $trigger.parents('.row-fluid').remove();
      $showMoreTarget.removeClass('withShowMore');
      if (Line.ProductGrid.isMasonryActive()) {
        $showMoreTarget.masonry('appended', $showMoreData);
      }

    });

    _trackShowMore($trigger.data('show-more-label'));
  }

  return {
    initialize: function() {
      if (showMoreTriggers.length) {
        _setupShowMoreTriggers();
      }
    }
  };
}());
