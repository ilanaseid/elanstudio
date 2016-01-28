var Line = window.Line || {};

/**
 * Drives add to cart notification and minicart display
 */

Line.Cart = (function() {
  'use strict';

  var _countSel = '.bag-count',
      _cartWrapSel = '#cartWrap',
      $_cartCount,
      $_miniCartTarget;

  // do any formatting for layout or localization of cart data
  function _formatCart(cart) {
    $.each(cart.line_items,function() {
      this.price = Math.ceil(this.price);
      // set special shipping status if variant calls for it
        if (this.variant.shipping_category_id !== 7) {
          this.variant.special_shipping = true;
        }
        if (this.variant.final_sale) {
          this.variant.final_sale = true;
        }
    });

    cart.item_total = Math.ceil(cart.item_total).toFixed(2);
    cart.total = Math.ceil(cart.total).toFixed(2);

    return cart;
  }

  // updates bag count in heading
  function _updateBagState(item_count) {
    $_cartCount.html(item_count);
  }

  // tallies the quantity of products for hidden line items
  function _quatityAfterN(cart,item_count,n) {
    var quantity = item_count,
        i;

    // only count if we actually have hidden items
    if (cart.line_items.length > n) {
      // pull the quantity of visible items out of total quantity
      for (i=0; i < n; i++) {
        quantity = quantity - cart.line_items[i].quantity;
      }
      return quantity;
    }

    return 0;
  }

  // changes the contents of the minicart HTML based on given cart object
  function _populateMiniCart(cart,item_count) {
    var data = {
          message: null,
          cart: _formatCart(cart),
          additional: _quatityAfterN(cart,item_count,3),
          item_count: item_count
        };

    $_miniCartTarget.html(Line.Util.safeTmplCompile('#template-minicart',data));
  }

  return {
    // registers events and lazy loads minicart display
    initialize: function() {
      $_miniCartTarget = $(_cartWrapSel);
      $_cartCount = $(_countSel);

      // preload minicart
      if ($_cartCount.length && $_cartCount.html() !== '0') {
        var item_count = 0;

        $.ajax({
          type: 'GET',
          url: '/cart.json',
          success: function(data,status,xhr) {
            if (data.error) {
              // document.location.href = '/cart';
            } else {
              $.each(data.line_items,function() {
                item_count = item_count + this.quantity;
              });
              _populateMiniCart(data, item_count);
            }
          },
          error: function(xhr,status,err) {
            // document.location.href = '/cart';
          }

        });
      } else {
        _populateMiniCart({
          line_items: []
        },0);
      }
    },

    // manages update calls for the minicart
    updateMiniCart: function(cart,item_count,notify) {
      var data = {
            message: 'JUST ADDED',
            cart: _formatCart(cart),
            additional: _quatityAfterN(cart,item_count,1)
          },
          notification;

      notify = notify ? notify : false;

      _updateBagState(item_count);
      _populateMiniCart(cart,item_count);

      data.cart.line_items.splice(1, data.cart.line_items.length);

      if (notify) {
        notification = Line.Util.safeTmplCompile('#template-minicart',data);
        if (notification.length) {
          Line.UI.displayNotification(notification);
        }
      }
    }
  };
}());
