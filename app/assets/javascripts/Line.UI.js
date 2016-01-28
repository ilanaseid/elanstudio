var Line = window.Line || {};

/**
 * Simplified UI widget enabling
 */

Line.UI = (function() {
  'use strict';

  var _notificationTimeout,
      _timeoutLength = 5000,
      _optionalContentCache = [];

  function _initNotification() {
    var $nb,
        content,
        autohide;

    // if the page loads with a notification, autohide
    if ($('.nb-staged').length) {
      $nb = $('.nb-staged');
      autohide = $('.nb-staged').data('autohide');
      content = $nb.html();

      $('body').imagesLoaded(function() {
        _displayNotification(content, autohide);
      });

    }

    // watch interactions to hide notifications
    $(window).on('provocation_toggle nav_panel_open cart_panel_open search_panel_toggle',_removeNotification);

    // watch close button on notification window
    $('body').on('click','.nb-wrap .btn-remove',function(e) {
      e.preventDefault();
      _removeNotification();
    });
  }

  // removes cart notification window from the DOM
  // [TBD: can this be abstracted]
  function _removeNotification() {
    var $nb = $('.nb-wrap');

    window.clearTimeout(_notificationTimeout);

    $nb.remove();
  }

  // hides / fades out cart notification window
  // [TBD: can this be abstracted]
  function _hideNotification() {
    var $nb = $('.nb-wrap');

    window.clearTimeout(_notificationTimeout);

    $nb.addClass('staged');
    // TODO: ? do we call _removeNotification or does it not matter?
  }

  // changes the contents of, then displays the cart notification window
  // [TBD: can this be abstracted]
  function _displayNotification(content, autohide) {
    var $nb;

    $('.nb-wrap').remove();

    $nb = $('<div class="nb-wrap staged"></div>');
    $nb.append(content);
    $nb.append('<button title="Close" type="button" class="btn-remove">×</button>');
    $('#bodyWrap').append($nb);
    window.setTimeout(function(){ $('.nb-wrap').removeClass('staged'); },5); // TODO: Why?

    window.clearTimeout(_notificationTimeout);

    if (autohide) {
      _notificationTimeout = window.setTimeout(_hideNotification, _timeoutLength);

      $('.nb-wrap').on('mouseover',function() {
        window.clearTimeout(_notificationTimeout);
       _notificationTimeout = window.setTimeout(_hideNotification, _timeoutLength);
      });
    }
  }

  function _initSecondaryCarousel($container) {

    $container
      .slick({
        dots: true,
        variableWidth: true,
        // cssEase: Line.UI.ANIM_EASING,
        speed: Line.UI.ANIM_DURATION,
        onInit: function() {
          var nextIndex = (this.currentSlide + 1 >= this.$slides.length) ? 0 : this.currentSlide + 1,
              prevIndex = (this.currentSlide - 1 < 0) ? this.$slides.length - 1 : this.currentSlide - 1;

          // set button text and chapter content
          this.$slides.eq(this.currentSlide).find('.chapter-content').animate({'opacity':'1'},'fast');
          this.$prevArrow.html('<span class="icon_leftShort"></span>' + Line.Util.truncateAtWord(this.$slides.eq(prevIndex).find('.title').text(),35,'…'));
          this.$nextArrow.html(Line.Util.truncateAtWord(this.$slides.eq(nextIndex).find('.title').text(),35,'…') + '<span class="icon_rightShort"></span>');
          Line.Track.event('chapterCarousel', 'load', (this.currentSlide+1)+'_of_'+this.$slides.length, 1);
        },
        onBeforeChange: function() {
          // hide chapter content and button text
          this.$prevArrow.html('<span class="icon_leftShort"></span>' + '');
          this.$nextArrow.html('' + '<span class="icon_rightShort"></span>');
          this.$slides.eq(this.currentSlide).find('.chapter-content').animate({'opacity':'0'},'fast');
        },
        onAfterChange: function() {
          var nextIndex = (this.currentSlide + 1 >= this.$slides.length) ? 0 : this.currentSlide + 1,
              prevIndex = (this.currentSlide - 1 < 0) ? this.$slides.length - 1 : this.currentSlide - 1;

          // set button text and chapter content
          this.$prevArrow.html('<span class="icon_leftShort"></span>' + Line.Util.truncateAtWord(this.$slides.eq(prevIndex).find('.title').text(),35,'…'));
          this.$nextArrow.html(Line.Util.truncateAtWord(this.$slides.eq(nextIndex).find('.title').text(),35,'…') + '<span class="icon_rightShort"></span>');
          this.$slides.eq(this.currentSlide).find('.chapter-content').animate({'opacity':'1'},'fast');
          Line.Track.event('chapterCarousel', 'advance', (this.currentSlide+1)+'_of_'+this.$slides.length, 1);
        }
      });


  }

  function _initSizeSelector() {
    // make sizeSelectors, checkbox edition only allow one selection
    $('body').on('click change','.sizeSelector [type=checkbox]',function() {
      var $this = $(this);

      if ($this.is(':checked')) {
        $this.parent().siblings().find('[type=checkbox]').attr('checked',false);
      }
    });

    // make the size selectors pass their spree variant id (ie size info) to the add-to-wishlist path
    $('.sizeSelector input').click(function(){
      // grab the wishlist link for this selector's product
      var wishListLink = $(this).parents('.hproduct').find('.wishlist-add');

      // protect against wishlist link not appearing (aka retail)
      if (wishListLink.length) {
        wishListLink.attr('href', Line.Util.setQueryParamVal('spree_variant_id',$(this).data('variant-id'),wishListLink.attr('href')));
      }
    });
  }

  function _shouldDisplayOptionalContent($toggle) {
    var test = true;

    if ((($toggle.data('optionalcontentinverse') === false) && !$toggle.is(':checked')) || (($toggle.data('optionalcontentinverse') === true) && $toggle.is(':checked'))) {
      test = false;
    }
    return test;
  }

  function _initOptionalContent() {
    // CASE 1: a singluar checkbox that toggles content
    //          input.optionalContentToggle[type=checkbox]
    // CASE 2: a set of radio buttons, grouped by name, that each has it's own content & should hide siblings content when activated
    //          input#A1.optionalContentToggle[type=radio][name=A]
    //          input#A2.optionalContentToggle[type=radio][name=A]
    //          input#A3.optionalContentToggle[type=radio][name=A]
    // CASE 3: a set of radio buttons, grouped by name, where not all options have their own content
    //          input#A1.optionalContentToggle[type=radio][name=A]
    //          input#A2.optionalContentToggle[type=radio][name=A]
    //          input#A3[type=radio][name=A].not(.optionalContentToggle)
    // STEP 1: FIND TOGGLEABLE ELEMENTS AND THEIR SIBLINGS
    // STEP 2: CONFIGURE CONTENT TO PROPER INTIAL STATE
    // STEP 3: WATCH FOR INTERACTIONS WITH TOGGLEABLE ELEMENTS AND THEIR SIBLINGS

    var $toggles = $('.optionalContentToggle'),
        $siblingsToMonitor = $toggles.siblings('[type=radio]').not('.optionalContentToggle');

    if ($toggles.length) {
      $toggles.each(function() {
        // create a wrapper around the target content to
        // on initialization, we just need to detach children of the content, not re-attach
        if (_shouldDisplayOptionalContent($(this)) === false) {
          _optionalContentCache[$(this).data('optionalcontenttarget')] = $($(this).data('optionalcontenttarget')).children().detach();
        }
      });

      // watch for direct interaction with all elements with content (ALL CASES)
      $toggles.on('click', function() {
        if ($(this).attr('name').length) { // CASE 2/3: loop through all elements in the group with content associated with them
          // only seek out the named elements with content (CASE 2)
          $('.optionalContentToggle[name="'+$(this).attr('name')+'"]').each(function() {
            if (_shouldDisplayOptionalContent($(this)) === false) {
              _optionalContentCache[$(this).data('optionalcontenttarget')] = $($(this).data('optionalcontenttarget')).children().detach();
            } else {
              $($(this).data('optionalcontenttarget')).append( _optionalContentCache[$(this).data('optionalcontenttarget')]);
            }
          });
        } else { // CASE 1: this is a singluar element
          if (_shouldDisplayOptionalContent($(this)) === false) {
            _optionalContentCache[$(this).data('optionalcontenttarget')] = $($(this).data('optionalcontenttarget')).children().detach();
          } else {
            $($(this).data('optionalcontenttarget')).append( _optionalContentCache[$(this).data('optionalcontenttarget')]);
          }
        }

      });

      // CASE 3 also watch for interaction with siblings
      $siblingsToMonitor.on('click',function() {
        // find the siblings *with* associated content, and then set them properly (matches as above sibling lookup)
        $('.optionalContentToggle[name="'+$(this).attr('name')+'"]').each(function() {
          if (_shouldDisplayOptionalContent($(this)) === false) {
            _optionalContentCache[$(this).data('optionalcontenttarget')] = $($(this).data('optionalcontenttarget')).children().detach();
          } else {
            $($(this).data('optionalcontenttarget')).append( _optionalContentCache[$(this).data('optionalcontenttarget')]);
          }
        });
      });
    }
  } // end _initOptionalContent function



  return {
    ANIM_DURATION: 800,
    ANIM_EASING: 'lineEase',

    displayNotification: function(content, autohide) {
      autohide = (typeof autohide === 'undefined') ? true : autohide;

      _displayNotification(content, autohide);
    },

    initSecondaryCarousel: function($carousel, responsive) {
      responsive = (typeof responsive === 'undefined') ? true : responsive;

      _initSecondaryCarousel($carousel, responsive);
    },

    initialize: function() {

      // initialize notification functionality
      _initNotification();

      // initialize optional content
      _initOptionalContent();


      // initialize accordion widgets
      // TODO: perf win to only doing this dom lookup on some page types??
      $('.accordion').simpleaccordion({
        easing: Line.UI.ANIM_EASING,
        duration: Line.UI.ANIM_DURATION,
        onInit: function() {
          // add the spans where we want them, with the proper starting classes
          var $headers = $(this).children('dt');
          $headers.each(function() {
            if ($(this).hasClass('sa-open')) {
              $(this).addClass('icon_upCaret-ia');
            } else {
              $(this).addClass('icon_downCaret-ia');
            }
          });
        },
        callback: function() {
          // loop through spans and set the span classes to their new value, depending on state of dt
          var $headers = $(this).parent().children('dt');
          $headers.each(function() {
            if ($(this).hasClass('sa-open')) {
              $(this).removeClass('icon_downCaret-ia').addClass('icon_upCaret-ia');
            } else {
              $(this).removeClass('icon_upCaret-ia').addClass('icon_downCaret-ia');
            }
          });

          Line.Track.event('accordion','open',$(this).text().trim());
        }
      });


      // initialize SizeSelector Stuff (checkboxes act as radios, wishlist functionality)
      _initSizeSelector();

      // watch for share modal links
      $('body').on('click','.lb',function(e) {
        var href = $(this).attr('href');
        e.preventDefault();

        $.magnificPopup.open({
          items: {
            src: href,
            type: 'ajax'
          },
          callbacks: {
            open: function() {
              Line.Track.pageView(href);
            }
          }
        });
      });

      $('.lb-tmpl').each(function() {
        // safety check for bad compilation / browser errors
        // note, we're not compiling at this time, just finding the template
        if (typeof $('#'+$(this).data('tmpl-id')).html() !== 'undefined') {
          $(this)
            .css('opacity','1')
            .css('cursor','pointer')
            .on('click',function(e) {
              var $this = $(this),
                  tmplId = $this.data('tmpl-id'),
                  tmplData = $this.data('tmpl-data'),
                  tmplHtml;

              // compile and use the templates
              tmplHtml = Line.Util.safeTmplCompile('#'+tmplId,tmplData);

              if (tmplHtml.length) {
                e.preventDefault();
                $.magnificPopup.open({
                  items: {
                    type: 'inline',
                    src: tmplHtml
                  },
                  callbacks: {
                    open: function() {
                      Line.Track.pageView(document.location.pathname+'/'+tmplId+''+tmplData.target);
                    }
                  }
                });
              }
            });
        }

      });

      // if link is in lightbox already, do another modal call and replace contents
      // if link is a full page, just let the link pass through
      $('body').on('click','.lb-same',function(e) {
        var $this = $(this),
            popupInstance;

        if ($this.parents('.lb-wrap').length) {
          e.preventDefault();
          popupInstance = $.magnificPopup.instance;
          popupInstance.updateStatus('loading', 'Loading...');
          popupInstance.content.html('');

          // note: replacing content inside of existing was problematic,
          // so grab content and then create new popup instance
          $.ajax({
            dataType: 'html',
            url: $this.attr('href'),
            context: $this,
            success: function(data,status,xhr) {
              Line.Track.pageView(this.attr('href'));
              $.magnificPopup.close();
              $.magnificPopup.open({
                items: {
                  type: 'inline',
                  src: data
                }
              });
            },
            error: function(xhr,status,err) {
              popupInstance.updateStatus('error', 'Error loading content...');
            }
          });
        }

      });

      // init sticky sidebar columns for PDP
      if ($('.mainProduct').length) {
        $('.mainProduct').imagesLoaded(function() {
          // load only if...

          // could fail if Line.e didn't do its thing
          if ($('body').is('.mq_notsmall')) {
            // initialize stickycolumn

            $('.mainProduct .span7').eq(0).stickycolumn({
              viewportTop: function() {
                return $('#contextualNav').outerHeight();
              },
              contentPadding: function() {
                var tallestContentHeight = 0;

                $('.sa-active>dd').each(function(i) {
                  tallestContentHeight = (tallestContentHeight > $(this).height()) ? tallestContentHeight : $(this).height();
                });
                return tallestContentHeight - $('.sa-active .sa-open+dd').height();
              }
            });
          }
        });
      }

      // init generic sticky columns - todo: perf: have to wait until images loaded here?
      $('body').imagesLoaded(function() {
        if ($('body').is('.mq_notsmall')) {
          $('.stickycolumn').stickycolumn({
            viewportTop: function() {
              return $('#contextualNav').outerHeight();
            }
          });
        }
      });

      // watch mediaqueries
      // * on small side destroy it
      $(window).on(Line.e.MQ_WIDTH_CHANGE+'.stickycolumn',function() {
        if (!$('body').is('.mq_notsmall')) {
          $('.mainProduct .span7, .stickycolumn').each(function() {
            if ($(this).data('plugin_stickycolumn')) {
              $(this).data('plugin_stickycolumn').destroy();
            }
          });
          $(window).off(Line.e.MQ_TOPNAV_CHANGE+'.stickycolumn');
        }
      });

     // open a modal when at /login to notify we are who we are (not the line messaging service)
    if(document.location.href.indexOf('login') > -1){
      // data show modal is to check if they are a spree current user, have been to the line more than once (dont show, prob recurring customer), and if they were redirected to login from something like /accounts (dont show modal)
      if($('.login').data().showModal === true) {
        $.magnificPopup.open({
          items: {
            src: '/s/about',
            type: 'ajax'
          },
          callbacks: {
            parseAjax: function(mfpResponse) {
              // mfpResponse.data is a "data" object from ajax "success" callback
              // for simple HTML file, it will be just String
              // You may modify it to change contents of the popup
              // For example, to show just #some-element:
              // mfpResponse.data = $(mfpResponse.data).find('#some-element');
              // mfpResponse.data must be a String or a DOM (jQuery) element
              mfpResponse.data = (mfpResponse.data).replace('offset2"', '" style="padding-bottom: 50px; padding-left: 30px;"');
            }
          }
        });
      }
    }

      // new window stuffs
      $('body')
        .on('click','.popup_facebook',function(e) {
          e.preventDefault();
          window.open(this.href,'share_fb','width=575,height=400');
        })
        .on('click','.popup_twitter',function(e) {
          e.preventDefault();
          window.open(this.href,'share_tw','width=575,height=400');
        })
        .on('click','.popup',function(e) {
          e.preventDefault();
          window.open(this.href);
        })
        .on('click','[rel=external]',function(e) {
          Line.Track.outbound(this.href);
        })
        .on('click','.social',function(e) {
          Line.Track.social($(this).data('social-network'),$(this).data('social-action'),$(this).data('social-target'),this.href);
          $.magnificPopup.close();
        })
        .on('click','.anchor',function(e) {
          e.preventDefault();
          var anchor = '#' + parseUri(this.href).anchor;

          Line.Containers.containerScrollToElm($(anchor));

          Line.Track.event('anchor','click',anchor);
        })
      ;

      // initilize mailto tracking
      $('[href^="mailto:"]').on('click',function(e){
        Line.Track.mailto(this.href);
      });

    }
  };
}());
