var Line = window.Line || {};

/**
 * Form handling and validation
 */

Line.Form = (function() {
  /* jshint -W040 */
  'use strict';

  // regexes via the html5 spec or https://github.com/dilvie/h5Validate/
  // var _email_re = new RegExp("/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/"), // html5 spec
  //     _number_re = new RegExp("/-?(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d+)?/");
  //     // _tel_re = new RegExp("/([\+][0-9]{1,3}([ \.\-])?)?([\(][0-9]{1,6}[\)])?([0-9A-Za-z \.\-]{1,32})(([A-Za-z \:]{1,11})?[0-9]{1,4}?)/");
      // _url_re = new RegExp("/(https?|ftp):\/\/(((([a-zA-Z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-zA-Z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-zA-Z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-zA-Z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-zA-Z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-zA-Z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-zA-Z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-zA-Z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-zA-Z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-zA-Z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-zA-Z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-zA-Z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-zA-Z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?/");


  // Clears form messages from specified form
  function _removeFormMessage($form) {
    $form.find('.alert').remove();
  }

  // updates or adds message to specified form
  function _updateFormMessage($form,msg,error) {
    var $target = $form.find('.form-messages'),
        $msg = $('<p class="alert"></p>');

    error = error ? 1 : 0;

    if (error) {
      $msg.addClass('alert-error').html(msg);
    } else {
      $msg.addClass('alert-success').html(msg);
    }

    $target.html($msg);

  }



  // basic form validation - leverage html5 forms options
  // make sure safari isn't screwing us
  function _validateForm($form) {
    var valid = true,
        $sizeSelector,
        $wordLimitedTextarea;


    // STEP 0: bypass function if we're explicitly not validating
    // if (!Modernizr.formvalidation || $form.is('[novalidate]')) {
    if ($form.is('[novalidate]')) {
      $form.attr('novalidate','novalidate'); // ie9 hack?
      return valid;
    }

    // STEP 1: clear existing error messages
    $form.find('.error').removeClass('error');
    $form.find('.inline-errors, .alert').remove();

    // STEP 2: signify we've validated at least once

    // set validatedOnce state
    $form.addClass('validatedOnce');


    // check customized validations before standard widgets - long term this might screw up form order/messaging
    // STEP 4: do custom validations
    // console.log('found size selector');
    $sizeSelector = $form.find('.sizeSelector');
    if ($sizeSelector.length) {
      // clear old messages
      $sizeSelector.find('h5 span').remove();

      if ($sizeSelector.find(':checked').length === 0) {
        valid = false;
        $sizeSelector.find('h5').append('<span class="inline-errors">'+Line.Util.getString('error_no_selected_size')+'</span>');
      } else {
        // console.log('valid size selector');
      }
    }

    $wordLimitedTextarea = $form.find('.wordLimit');
    $wordLimitedTextarea.each(function() {
      if ($(this).next().is('.wc-error')) {
        $(this).parent().addClass('error');
        valid = false;
      }
    });


    // STEP 3: do basic html5 attribute based validation
    //if ($form[0].querySelectorAll(':invalid')) {

    if (Modernizr.formvalidation) {
      if ($form.find(':invalid').length) {
        valid = false;
      }
    }

    // for old browsers, some quick validations
    if (!Modernizr.formvalidation) {
      // TODO: rearchitect - loop though each field, find its required, base re, other pattern so we don't have race conditions, unwanted DOM lookups, or poor messaging

      // check email fields
      // $form.find('[type=email]').map(function() {
      //   if ($(this).val() != '') {
      //     if (!_email_re.test($(this).val())) {
      //       $(this).parent().addClass('error').find('label').before('<p class="inline-errors">'+Line.Util.getString('error_not_an_email')+'</p>');
      //       valid = false;
      //     }
      //   }
      // });

      // check tel fields
      // problematic, see http://www.whatwg.org/specs/web-apps/current-work/multipage/states-of-the-type-attribute.html#telephone-state-(type=tel)
      // TODO: simply test for min # of 0-9a-zA-Z?
      // $form.find('[type=tel]').map(function() {
      //   if ($(this).val() != '') {
      //     if (!_tel_re.test($(this).val())) {
      //       $(this).parent().addClass('error').find('label').before('<p class="inline-errors">'+Line.Util.getString('error_invalid')+'</p>');
      //       valid = false;
      //     }
      //   }
      // });

      // check number fields
      // $form.find('[type=number]').map(function() {
      //   if ($(this).val() != '') {
      //     if (!_number_re.test($(this).val())) {
      //       $(this).parent().addClass('error').find('label').before('<p class="inline-errors">'+Line.Util.getString('error_invalid')+'</p>');
      //       valid = false;
      //     }
      //   }
      // });

      // check url fields
      // $form.find('[type=url]').map(function() {
      //   if ($(this).val() != '') {
      //     if (!$(this).val().match(_url_re))) {
      //       $(this).parent().addClass('error').find('label').before('<p class="inline-errors">'+Line.Util.getString('error_not_a_url')+'</p>');
      //       valid = false;
      //     }
      //   }
      // });

      // check required fields
      $form.find('[required]').not('[disabled]').map(function() {
        var $field = $(this);

        // review checkboxes, then textfields
        if ($field.is('[type=checkbox]')) {
          if (!$(this).is(':checked')) {
            $(this).parent().addClass('error').find('label').after('<p class="inline-errors">'+Line.Util.getString('error_blank')+'</p>');
            valid = false;
          }
        } else {
          if ($(this).val() === '') {
            $(this).parent().addClass('error').find('label').before('<p class="inline-errors">'+Line.Util.getString('error_blank')+'</p>');
            valid = false;
          }
        }
      });

    }

    return valid;
  }

   // submits ANY generic form, wholesale, via ajax, with an HTML response
  function _sumbitGenericXHRForm(e, $form) {
    var $formClone,
        popupInstance;

    // var valid = true;
    $form = ($form == null) ? $(this) : $form;
    $formClone = $form.clone();

    if ($form.parents('.lb-wrap').length) {
      e.preventDefault();

      popupInstance = $.magnificPopup.instance;
      popupInstance.updateStatus('loading', 'Loading...');
      popupInstance.content.html('');

      // manage lightbox state (do this via .UI?)
      // generic serialization and submittion of 1 form in overlay
      $.ajax({
        type: $formClone.attr('method'),
        url: $formClone.attr('action'),
        data: $formClone.serialize(),
        context: $formClone,
        cache: false,
        dataType: 'html',
        success: function(data,status,xhr) {
          if (this.data('conversion-path')) {
            Line.Track.pageView(this.data('conversion-path'));
          } else {
            Line.Track.pageView(this.attr('action'));
          }

          if (this.data('conversion-pixels')) {
            Line.Track.conversion(this.data('conversion-pixels'));
          }


          $.magnificPopup.close();
          $.magnificPopup.open({
            items: {
              type: 'inline',
              src: data
            }
          });
        },
        error:  function(xhr,status,err) {
          popupInstance.updateStatus('error', 'Error loading content...');
        }
      });

    }
  }


  // handles the error response from a generic form w/ HTML
  // function _handleGenericXHRFormError(xhr,status,err) {
  //   alert('error xhr');
  // }


  // submits ANY generic form, wholesale, via ajax, with a JSON response
  function _sumbitGenericJSONForm(e, $form) {
    e.preventDefault();
    $form = ($form == null) ? $(this) : $form;

    // generic serialization and submittion of 1 form in overlay
    $.ajax({
      type: $form.attr('method'),
      url: $form.attr('action'),
      data: $form.serialize(),
      context: $form,
      cache: false,
      dataType: 'json',
      success: _handleGenericJSONFormSuccess,
      error: _handleGenericJSONFormError
    });
  }

  // handles the succes response from a generic form w/ JSON output
  function _handleGenericJSONFormSuccess(data,status,xhr) {
    var $form = $(this); // via $.ajax context

    $form.replaceWith('<p class="alert alert-success">'+Line.Util.getString('success_unknown')+'</p>');

    if ($form.data('conversion-path')) {
      Line.Track.pageView($form.data('conversion-path'));
    } else {
      Line.Track.pageView($form.attr('action'));
    }

    if (this.data('conversion-pixels')) {
      Line.Track.conversion(this.data('conversion-pixels'));
    }
  }

  // handles the error response from a generic form w/ JSON
  function _handleGenericJSONFormError(xhr,status,err) {
    var $form = $(this); // via $.ajax context

    // a 404 means we got directed and probably have an HTML response
    if (xhr.status !== 404) {
      // Unprocessable Entity: expected form validation / other error
      if (422 === xhr.status) {
        // draw inline errors
        _displayFormErrors($form,xhr.responseJSON);
      } else {
        // ???
        // some unknown error with bad JSON response
        if ($form.find('.form-messages').length) {
          $form.find('.form-messages').append('<p class="alert alert-error">'+Line.Util.getString('error_unknown')+'</p>');
        } else {
          alert(Line.Util.getString('error_unknown'));
        }
      }
    } else {
      if ($form.find('.form-messages').length) {
        $form.find('.form-messages').append('<p class="alert alert-error">'+Line.Util.getString('error_unknown')+'</p>');
      } else {
        alert(Line.Util.getString('error_unknown'));
      }
    }
  }


  //
  function _submitPopulateCart(e, $form, notify) {
    /* jshint -W040 */
    var action = $form.attr('action') + '.json';

    e.preventDefault();
    $form = ($form == null) ? $(this) : $form;
    notify = notify ? notify : true;

    // start us off
    _removeFormMessage($form);
    $form.find('[type=submit]').prop('disabled',true);

    // make the update request
    $.ajax({
      type: $form.attr('method'),
      url: action,
      data: $form.serialize(),
      context: $form,
      cache: false,
      dataType: 'json',
      success: function(data,status,xhr) {
        var $form = $(this), // via $.ajax context
            item_count = 0;

        $form.find('[type=submit]').prop('disabled',false);

        // check if we have a business rules error
        if (data.error) {
          _updateFormMessage($form,data.error,true);
        } else {
          window.jsonResponse = data;
          $.each(data.line_items,function() {
            item_count = item_count + this.quantity;
          });
          _updateFormMessage($form, Line.Util.getString('addtocart_success'), false);
          Line.Cart.updateMiniCart(data, item_count, notify);
          if ($form.parents('.item.quickshop').length) {
            Line.Track.pageView(action.replace('.json','/quickshop'));
          } else {
            Line.Track.pageView(action.replace('.json',''));
          }

        }
      },
      error: _handleGenericJSONFormError
    });
  }

  function _submitUpdateLineItem($item,quantity,notify) {
    var url = '/cart.json';

    quantity = quantity ? quantity : 0;
    notify = notify ? notify : false;

    // make the update request
    $.ajax({
      type: 'POST',
      url: url,
      data: {
        '_method': 'PATCH',
        'authenticity_token': $('meta[name=csrf-token]').attr('content'),
        'order[line_items_attributes][0][id]': $item.data('line-item-id'),
        'order[line_items_attributes][0][quantity]': quantity
      },
      context: $item,
      cache: false,
      dataType: 'json',
      success: function(data,status,xhr) {
        var $form = $(this), // via $.ajax context
            item_count = 0;

        $form.find('[type=submit]').prop('disabled',false);

        // check if we have a business rules error
        if (data.error) {
          _updateFormMessage($form,data.error,true);
        } else {
          window.jsonResponse = data;
          $.each(data.line_items,function() {
            item_count = item_count + this.quantity;
          });
          Line.Cart.updateMiniCart(data, item_count, notify);
          Line.Track.pageView(url.replace('.json',''));
        }
      },
      error: _handleGenericJSONFormError
    });
  }

  // takes a newsletter signup and submits via ajax, looking for HTML partial rather than JSON
  // TDOD: abstract this more, maybe options on generic XHR for content replacement targets
  function _submitNewsletterXHR(e, $form) {
    var $banner = $('.banner-fixedbottom-2'),
        $formClone;

    e.preventDefault();

    $form = ($form == null) ? $(this) : $form;

    $formClone = $form.clone();

    $banner.find('.banner_step').remove();

    $.ajax({
      type: $formClone.attr('method'),
      url: $formClone.attr('action'),
      data: $formClone.serialize(),
      context: $formClone,
      cache: false,
      dataType: 'html',
      success: function(data,status,xhr) {

        if (this.data('conversion-path')) {
          Line.Track.pageView(this.data('conversion-path'));
        } else {
          Line.Track.pageView(this.attr('action'));
        }

        if (this.data('conversion-pixels')) {
          Line.Track.conversion(this.data('conversion-pixels'));
        }

        // QUICK HACK TO WORK WITH MODAL
        if ($('#top-banner-content').length && $('#top-banner-content').css('display') === 'block') {
          Line.FixedBanner.postFormSubmittion();
        } else {
          $banner.append(data);
          $banner.find('input[type=text]').eq(0).focus();
        }
      },
      error:  function(xhr,status,err) {
        $banner.append('<div class="banner_step">Error loading content...</div>');
      }
    });
  }

  // displays inline form errors
  function _displayFormErrors($form,errorJSON) {
    var pattern = null,
        err = null,
        $li,
        $input;

    // loop through the form and see if we have fields with errors
    // todo: how fragile is this code? matching nested or looped objects, etc

    $form.find('.inputs li').each(function(i) {
      $li = $(this);
      $input = $li.find('input,textarea,select');

      if ($input.length) {
        pattern = $input.attr('name').split(/[\[\]]/)[1];
        err = errorJSON[pattern];
        // console.log(err);

        // see if we have an error in the json that matches this field
        if (err) { // if we have an error in the json, remove error states
          err = err.join(', ');

          $li.addClass('error')
              .find('.inline-errors').remove();
          $li.find('label').before('<p class="inline-errors">'+err+'</p>');
        } else { // if we do have an error, add error states
          $li.removeClass('error')
              .find('.inline-errors').remove();
        }
      }

    });
  }

  return {
    initialize: function() {
      // test validation
      //$('body').on('submit','form',_validateForm);

      // watch every form on the site and decide what to do with it
      // form can be handled in this file or passed through to another object/partial to be managed
      $('body').on('submit','form',function(e) {
        var $form = $(this),
          submitted = $(this).is('.submitonce.submitted');


        // gut whole process if we're not intended to submit again.
        if (submitted) {
          e.preventDefault();
          return;
        }

        // validate form
        if (_validateForm($form)) {
          if ($form.is('.xhr')) {
            _sumbitGenericXHRForm(e,$form);
          } else if ($form.is('.json')) {
            _sumbitGenericJSONForm(e,$form);
          } else if ($form.is('.submitonce')) {
            $form.addClass('submitted');
            // now pass thorugh...
          } else if ($form.is('.populateCart')) {
            _submitPopulateCart(e,$form);
          } else if ($form.is('.newsletterSubscribeXHR')) {
            _submitNewsletterXHR(e,$form);
          } else if ($form.is('.accountManagement')) {
            Line.Account.submitAccountManagementForm(e,$form);
          }
          // else just pass thorugh

        } else {
          // form is invalid, so don't submit
          e.preventDefault();
        }
      });
    },

    removeLineItem: function(that) {
      var $that = $(that);

      // only submit once
      if (!$that.is('.submitted')) {
        $that.addClass('submitted');
        $that.parents('.line-item').animate(
          { opacity: '0.22' },
          Line.UI.ANIM_DURATION,
          Line.UI.ANIM_EASING
        );
        _submitUpdateLineItem($that.parents('.line-item'),0);
      }

    },

    // Clears form messages from specified form
    removeFormMessage: function($form) {
      _removeFormMessage($form);
    },

    // updates or adds message to specified form
    updateFormMessage: function($form,msg,error) {
      _updateFormMessage($form,msg,error);
    }
  };
}());
