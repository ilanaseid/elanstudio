var Line = window.Line || {};

Line.BookingWidget = (function() {

  'use_strict';

  // var launchableWidget = document.getElementById('brickwork-widget') || false;

  function _checkAndLaunchWidget() {
    // _widgetBlock();
    _enableWidget();
  }

  function _widgetBlock() {
    var path = window.location.pathname.split('/'),
        gridItems = $('ul.pl li.item'),
        target = {
          fashion: path.indexOf('fashion'),
          home: path.indexOf('home'),
          newArrival: path.indexOf('new')
        }, i, num, templateEl, randomItem,
        gridWidgetSource, widgetTemplate, context, element, k;

    for (i in target) {
      if (target[i] < 0) {
        delete target[i];
      }
    }

    if (gridItems.length && !$.isEmptyObject(target)) {
      num = Math.floor(Math.random() * (10 - 1 + 1)) + 1;
      templateEl = $('#item-grid-booking-widget');

      if (num < 2 || (Line.User.getUserClass() === 'unknown' && templateEl.data('shopView') < 2)) {
        randomItem = gridItems.eq(Math.floor(Math.random() * gridItems.length));
        gridWidgetSource = templateEl.html();
        widgetTemplate = Handlebars.compile(gridWidgetSource);
        context = {};

        for (k in target) {
          if (k === 'fashion') {
            context.title = 'Want a closer look?';
            context.description = 'Find your perfect fit at our offline home. Stop by or make an appointment today.';
          } else if (k === 'home') {
            context.title = 'Design for Living';
            context.description = 'Create your ideal interior at our offline home.';
          } else {
            context.title = 'Want a closer look?';
            context.description = 'Find your perfect fit at our offline home. Stop by or make an appointment today.';
          }
        }

        element = widgetTemplate(context);
        $(element).insertBefore(randomItem);
        console.log('done');
      }
    }
  }

  function _enableWidget() {
    (function (d, s, id) {
      var t, js, fjs = d.getElementsByTagName(s)[0];
      if (d.getElementById(id)) { return; }
      js = d.createElement(s); js.id = id;
      js.src = '//theline.brickworksoftware.com/widgets/appointment.js?id=6';
      fjs.parentNode.insertBefore(js, fjs);
      (t = { _e: [], ready: function (f) { t._e.push(f); } });
    }(document, 'script', 'brickwork-widget-6'));

    // CALLBACK REGISTRATION (FROM BRICKWORK)
    document.body.addEventListener('Brickwork:appointment_created', apt_handler, false);
    function apt_handler(e) {
      // alert('Appointment '+e.detail.appointment_id+' was created at store '+e.detail.store_id+'!');
    }
  }

  return {
    initialize: function() {
      _checkAndLaunchWidget();
    },
    setHeight: function() {
      var widget = $('#grid-widget');
      widget.attr('style', 'height: ' + (widget.prev().find('.item-image').height() + 50) + 'px;');
    }
  };

}());
