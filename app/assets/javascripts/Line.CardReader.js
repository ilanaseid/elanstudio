
var Line = window.Line || {};

Line.CardReader = (function() {
  'use strict';

  var buffer = '',
      timeout = 100,
      readerTimeout = null,
      error_start = 'é'.charCodeAt(0),
      track_start = '%'.charCodeAt(0),
      track_end = '?'.charCodeAt(0),
      isError = false,
      field_separator = '^',
      line_separator = '?',
      started = false,
      finished = false,
      results = null;

  function _parseBuffer(content) {
    var fields,
        lines,
        results = {
          error: false,
          card_number: null,
          card_month: null,
          card_year: null
        };

    fields = content.split(field_separator);

    if (fields.length >= 2) {
      lines = fields[2].split(line_separator);

      if (lines.length >= 2) {
        results.card_number = lines[1].split('=')[0].substring(1);
        // Y2100 bug!
        results.card_year = '20'+lines[1].split('=')[1].substring(0,2);
        results.card_month = parseInt(lines[1].split('=')[1].substring(2,4),10);
      } else {
        results.error = true;
      }
    } else {
      results.error = true;
    }

    return results;

  }

  return {

    initialize: function() {

      // watch all page keystrokes for starting character
      $(window).on('keypress', function(e) {

        if (!started && ((e.which === track_start) || (e.which === error_start))) {
          // we have the beginning of a read

          e.stopImmediatePropagation();
          e.preventDefault();

          buffer += String.fromCharCode(e.which);
          started = true;

          if (e.which === error_start) {
            isError = true;
          }


          // dump out if timout is up
          window.clearTimeout(readerTimeout);
          readerTimeout = window.setTimeout(Line.CardReader.flushBuffer,timeout);

        } else if (started && (e.which === track_end)) {
          // we have the last character of a read
          e.stopImmediatePropagation();
          e.preventDefault();

          buffer += String.fromCharCode(e.which);
          finished = true;

          // dump out if timout is up
          window.clearTimeout(readerTimeout);
          readerTimeout = window.setTimeout(Line.CardReader.flushBuffer,timeout);

        } else if (started && finished && e.which === 13) {
          // we're ready to send the input
          e.stopImmediatePropagation();
          e.preventDefault();
          window.clearTimeout(readerTimeout);

          if (!isError) {
            results = _parseBuffer(buffer);
            if (!results.error) {
              $('#card_number').val(results.card_number);
              $('#card_month').val(results.card_month);
              $('#card_year').val(results.card_year);
              $('#card_code').focus();
            } else {
              alert('error reading swipe card');
            }

          } else {
            alert('error reading swipe card');
          }


          started = false;
          finished = false;
          buffer = '';
          isError = false;
          results = null;

        } else if (started) {
          // we're building the buffer
          e.stopImmediatePropagation();
          e.preventDefault();
          buffer += String.fromCharCode(e.which);

          // dump out if timout is up
          window.clearTimeout(readerTimeout);
          readerTimeout = window.setTimeout(Line.CardReader.flushBuffer,timeout);

        } else {
          // passthrough

        }
      });

    },

    flushBuffer: function() {
      isError = false;
      started = false;
      finished = false;
      window.clearTimeout(readerTimeout);
      $(':focus').val($(':focus').val() + buffer);
      buffer = '';
    }
  };
}());