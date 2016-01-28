var Line = window.Line || {};

/**
 * Generic utility functions
 */

Line.Util = (function() {
  'use strict';

  return {
    // searches for key in the STRINGS array which can be located in page templates
    // STRINGS should contain just text strings / output of localization so they don't live in JS files
    // used to prevent JS undefined errors if STRINGS is not defined
    // accepts 1 replacement value for '%S' found in string
    getString: function(key,replaced) {
      if (typeof STRINGS !== 'undefined') {
        if (typeof replaced !== 'undefined')  {
          var text = (STRINGS[key]) ? STRINGS[key] : key;
          return text.replace('%S',replaced);
        } else {
          return (STRINGS[key]) ? STRINGS[key] : key;
        }
      }
      return key;
    },

    // does a simple string replace for %S
    // but do it safely because we might have to pass null as the pattern
    stringReplace: function(text,template) {
      if (template == null) {
        return text;
      } else {
        return template.replace('%S',text);
      }
    },

    // uses the parseUri function to return a value for a query param
    // takes optional uri
    getQueryParamVal: function(param,uri) {
      var val = null,
          parsedUri = uri ? parseUri(uri) : parseUri(document.location.href);

      if (typeof parsedUri.queryKey[param] !== 'undefined') {
        val = parsedUri.queryKey[param];
      }

      parsedUri = null;
      return val;
    },

    // performs replacement on query params in a given elements href attr
    setQueryParamVal: function(param, val, uri) {
      var re = new RegExp('([?|&])' + param + '=.*?(&|$)', 'i'),
          sep = uri.indexOf('?') !== -1 ? '&' : '?';

      uri = uri ? uri : document.location.href;

      if (uri.match(re)) {
        uri = uri.replace(re, '$1' + param + '=' + val + '$2');
      } else { // just add it to the end
        uri = uri + sep + param + '=' + val;
      }

      return uri;
    },

    // safely performs a template compile. protects against targeted template not being loaded
    // returns empty string on failure
    safeTmplCompile: function(tmplSel,data) {
      var $tmpl = $(tmplSel),
          compiled = '';

      data = data ? data : {};

      if (typeof $tmpl.html() !== 'undefined') {
        compiled = (Handlebars.compile($tmpl.html()))(data);
      } else {
        Line.Track.event('systems','template_missing',tmplSel);
      }

      return compiled;
    },

    // truncates a string at the end of the word, keeping it under a specific char count
    // example truncateAtWord("Natural Glow: Fresh and Easy Summer Beauty",10) return's "Natural"
    truncateAtWord: function(text, length, ellipsis) {
      var chunks = text.split(' '),
          truncated = '',
          i;

      ellipsis = (typeof ellipsis !== 'undefined') ? ellipsis : '';

      for (i = 0; i < chunks.length; i++) {
        if ((truncated.length + chunks[i].length + 1) < length) {
          truncated = truncated + chunks[i] + ' ';
        } else {
          truncated = truncated.trim();
          break;
        }
      }

      if (truncated !== text) {
        truncated = truncated + ellipsis;
      }

      return truncated;
    }
  };
}());
