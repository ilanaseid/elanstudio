var Line = window.Line || {};

/**
 * turns site message link in top nav to trigger notificaiton window instead
 */

Line.SiteMessage = (function() {
  'use strict';

  return {
    initialize: function() {
      // watch for site message click - don't use id since it's duplicated
      $('.siteMessageItem button').on('click',function(e) {

        var notificationContent = null;

        // STEP 1: find source of notification content
        notificationContent = $('#'+$(this).data('notification-id')).html();

        // STEP 2: display notification if we found content
        if (notificationContent) {
          Line.UI.displayNotification(notificationContent, false);
          Line.Track.event('notification','click',$(this).text());
        }
      });
    }
  };
}());
