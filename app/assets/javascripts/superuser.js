//= require Line.CardReader
//= require Line.Pos
//= require_self

(function($){
  'use strict';

  $(document).ready(function() {
    // initialize card reader monitor
    if ($('#checkout_form_payment').length && $('body').is('.u_staff_retail')) {
      Line.CardReader.initialize();
    }

    // initialize superuser views
    if ($('body').is('.has_superuser_ui')) {
      Line.Pos.initialize();
    }
  });
})(jQuery);
