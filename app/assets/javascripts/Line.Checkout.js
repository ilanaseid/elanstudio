var Line = window.Line || {};

/**
 * Spree Form handling and api work
 */

Line.Checkout = (function() {
  /* jshint -W040 */
  'use strict';

  var _countryStates = [];

  // puts the unshippable notice in a lightbox if we're in a non small site
  function _displayUnshippableNotice($content) {
    var $html;

    if ($('body').is('.mq_notsmall') && $content.length) {
      $html = $content.clone();
      $html.removeAttr('id')
          .addClass('lb-wrap')
          .addClass('lb-wrap-6');
      $html.find('.span12')
          .addClass('span6')
          .removeClass('span12')
          .removeClass('offset2');

      $.magnificPopup.open({
        items: {
          src: $html,
          type: 'inline'
        }
      });
    }
  }

  // Manages associated State+Country feilds, based on cached data
  function _updateStateField($country) {
    var $select,
        $input;

    // double check we have data
    if (_countryStates.length >= 1) {
      // NOTE: WARNING! grouping by the parent fieldset or OL would be easy,
      // but we need to have that element in the fragment of a tree when removed from the dom as hidden optional content, too
      $select = $country.parents('ol').find('select[id$=state_id]');
      $input = $country.parents('ol').find('input[id$=state_name]');

      // if this country has states draw a select
      if (typeof _countryStates[$country.val()] !== 'undefined') {
        $select.children().remove();
        // add initial blank: TODO: make this optional
        $select.append('<option value=""></option>');

        $.each(_countryStates[$country.val()],function() {
          if ($select.data('default-selected') === this.id) {
            $select.append('<option value="'+this.id+'" selected="selected">'+this.name+'</option>');
          } else {
            $select.append('<option value="'+this.id+'">'+this.name+'</option>');
          }
        });

        $select.removeAttr('disabled');
        $input.attr('disabled','disabled');
        $input.parents('li').css('display','none');
        $select.parents('li').css('display','block');
      } else {
        $select.attr('disabled','disabled');
        $input.removeAttr('disabled');
        $select.parents('li').css('display','none');
        $input.parents('li').css('display','block');
      }
    }
  }

  // Initializes associated State+Country feilds, after getting JSON Data from spree
  function _initializeStateFields($countries) {
    // set default appearance for fields
    // add event handlers to watch for country changes

    if ($countries.length) {
      if (_countryStates.length < 1) {
        $.ajax({
          type: 'get',
          url: '/api/states.json',
          cache: true,
          dataType: 'json',
          success: function(data,status,xhr) {
            // process returned data
            $.map(data.states, function(val, i) {
              if (typeof _countryStates[val.country_id] !== 'undefined') {
                _countryStates[val.country_id].push(val);
              } else {
                _countryStates[val.country_id] = [val];
              }
            });

            $countries.each(function() {
              // update select state
              _updateStateField($(this));
            }).on('change',function(){
              // update select state
              _updateStateField($(this));
            });
        },
          error: function() {
            // alert(Line.Util.getString('error_unknown'));
          }
        });
      } else {
        $countries.each(function() {
          _updateStateField($(this));
        }).on('change',function(){
          _updateStateField($(this));
        });
      }
    }
  }

  return {
    initialize: function() {
      // display shipping issues notice
      _displayUnshippableNotice($('#unshippableNotice'));

      // watch for country + state field combos
      _initializeStateFields($('select[id$=country_id]'));

      // initialize wordcount plugin
      $('.wordLimit').wordcount();

    }
  };
}());
