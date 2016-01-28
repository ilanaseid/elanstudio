var Line = window.Line || {};

/**
 * Drives retail staff user POS
 */

Line.Pos = (function() {
  /* jshint -W040 */
  'use strict';

  var _location_id = 1, // TODO: is this a sane default to assume?
      _num_locations = 1; // TODO: ok to hardcode this? When using jquery object without form loaded async breaks table creation


  function _handleLocationChange() {
    var $form = $(this).parents('form');

    $.ajax({
      type: $form.attr('method'),
      url: $form.attr('action'),
      data: $form.serialize(),
      context: $form,
      cache: false,
      dataType: 'json',
      success: function(data,status,xhr) {
        // reload the current page so we don't have to rebuild sidebar cart/states
        window.location.reload();
      },
      error: function(xhr,status,err) {
        alert(Line.Util.getString('error_unknown'));
      }
    });
  }

  function _monitorLocationEvents() {
    // don't use ID because this is inserted multiple times
    $('.select_stock_location_id').on('change',_handleLocationChange);
  }

  function _buildInventoryTable(inventory_json, $table_target) {

    var r,
        c,
        $tr,
        num_columns = inventory_json.labels.length + 1,
        num_rows = _num_locations + 1,
        $table = $('<table class="pos-inventory"><col><tbody>'),
        $location_array = $('#order_stock_location_id').children('option');

    // remove share and wishlist
    $table_target.children('.nav').empty();

    // build top row for sizes
    for(r = 0; r < 1; r++){
      $tr = $('<tr class="sizes"><td></td>');

      for (c = 1; c < num_columns; c++) {
        $('<td></td>').text(inventory_json.labels[c-1]).appendTo($tr); //fill in labels based on variants
      }
      $tr.appendTo($table);
    }

    // build location and stock info
    for(r = 1; r < num_rows; r++){
      $tr = $('<tr>');

      if (_location_id === r) {
        $tr.addClass('active-location');
      }

      $('<td class="location"></td>').text($location_array.eq(r-1).text()).appendTo($tr); //fill in location labels
      for (c = 1; c < num_columns; c++) {
        if (num_columns > 2) {
          $('<td></td>').text(inventory_json[r][c-1]).appendTo($tr); //fill in stock info if variant
        } else {
          $('<td></td>').text(inventory_json[r]).appendTo($tr); //fill in stock info if master variant only
        }
      }
      $tr.appendTo($table);
    }
    $table.appendTo($table_target);
  }

  function _sizeSelectionAddToCartUI($item, $location_sum, $form_add_to_cart, $form_sizes) {
    if ($location_sum !== 0) {
      //enable the add-to-cart button
      $form_add_to_cart.prop('disabled', false);
      $form_add_to_cart.attr('type', 'submit');

      //work through checkboxes
      $item[_location_id].map(function(i, n) {
        if(i !== 0) {
          $form_sizes.eq(n).children('input').prop('disabled', false);
          $form_sizes.eq(n).children('.label').removeClass('unavailable').addClass('available');
        } else {
          $form_sizes.eq(n).children('input').prop('disabled', true);
          $form_sizes.eq(n).children('.label').removeClass('available').addClass('unavailable');
        }
      });

      $form_sizes.parent('ul').parent('.sizeSelector').removeClass('hide');
    } else {
      //disable the add-to-cart button
      $form_add_to_cart.prop('disabled', true);
      $form_add_to_cart.attr('type', 'submit');
      ///TBD : NEED TO FIX FOR NON VARIANT
      $item[_location_id].map(function(i, n) {
        $form_sizes.eq(n).children('input').prop('disabled', true);
        $form_sizes.eq(n).children('.label').removeClass('available').addClass('unavailable');
      });

      $form_sizes.parent('ul').parent('.sizeSelector').removeClass('hide');
    }
  }

  // looks for template in page and makes changes to nav and contextual nav
  function _buildRetailNav() {
    var tmplHtml;

    // inject nav and form stuff - be precise so we don't screw with Line.Nav.js
    // safety check for bad compilation / browser errors
    tmplHtml = Line.Util.safeTmplCompile('#template-pos-nav');
    if (tmplHtml.length) {
      $('.nav-header-1','.mainnav-2, #mainnav-2-target')
        .each(function() {
          // remove all but last 2 elements
          $(this).children().slice(0, -2).remove();
        })
        .prepend(tmplHtml);
      _monitorLocationEvents();
    }

    // form must be in the page or this fails
    if ($('#order_stock_location_id option:selected').length) {
      _location_id = parseInt($('#order_stock_location_id option:selected').attr('value'), 10);
    }

  }

  function _UXforPOS() {
    var $item,
        $item_inventory,
        $inventory_sum,
        $location_sum,
        $table_target,
        $form_sizes,
        $form_add_to_cart,
        master_locations_array,
        variant_locations_array;


    // build nav first
    _buildRetailNav();

    // then build product changes
    if ($('[data-inventory]').length) {
      $('[data-inventory]').each( function() {
        $item = $(this);
        //show prices
        $('.price').each(function() {
          $item.removeClass('price').addClass('pos-price');
        });

        $item_inventory = $item.data('inventory');
        $inventory_sum = 0;
        $location_sum = 0;
        master_locations_array = [],
        variant_locations_array = [];

        $.each($item_inventory, function(key, value) {
          if (key !== 'labels') {
            master_locations_array.push(parseFloat(key));
          }
        });

        if ($item_inventory[1].length > 1) {
          //concatenate all the arrays
          $.each(master_locations_array, function(key, value) {
            variant_locations_array.push($item_inventory[value]);
           });

          //flatten them into one array
          $.map(variant_locations_array, function recurs(n) {
            return ($.isArray(n) ? $.map(n, recurs): n);
          });

          $.each(variant_locations_array[0],function(){$inventory_sum+=parseFloat(this) || 0;});
          $.each($item_inventory[_location_id],function(){$location_sum+=parseFloat(this) || 0;});


        } else {
          $.each(master_locations_array, function(key, value) {
            $inventory_sum += $item_inventory[value][0];
          });
          $location_sum = $item_inventory[_location_id][0];
        }

        if ($location_sum !== 0) {
          $item.addClass('pos-available');
        } else if ($inventory_sum === 0) {
          $item.addClass('pos-sold-out');
        } else {
          $item.addClass('pos-avail-other');
        }

        if($item.hasClass('row-fluid')) {  // if on PDP
          // Build the stock inventory table
          $table_target = $item.children('.span7');
          _buildInventoryTable($item_inventory, $table_target);

          // Enable /disable add to cart and sizing checkboxes
          $form_sizes = $table_target.children('form').children('.sizeSelector').children('ul').children('li'),
          $form_add_to_cart = $table_target.children('form').children('fieldset').children('input#add-to-cart'),
          _sizeSelectionAddToCartUI($item_inventory, $location_sum, $form_add_to_cart, $form_sizes);

        } else { // product grid item - built onclick
          $item.one('click', function() {
            $item = $(this);
            //reset all the counters from the each loop above to zero and calc for each item on click
            $item_inventory = $item.data('inventory');
            $inventory_sum = 0;
            $location_sum = 0,
            master_locations_array = [],
            variant_locations_array =[];

            $.each($item_inventory, function(key, value) {
              if (key !== 'labels') {
                master_locations_array.push(parseFloat(key));
              }
            });

            if ($item_inventory[1].length > 1) {
              //concatenate all the arrays
              $.each(master_locations_array, function(key, value) {
                variant_locations_array.push($item_inventory[value]);
               });

              //flatten them into one array
              $.map(variant_locations_array, function recurs(n) {
                return ($.isArray(n) ? $.map(n, recurs): n);
              });

              $.each(variant_locations_array[0],function(){$inventory_sum+=parseFloat(this) || 0;});
              $.each($item_inventory[_location_id],function(){$location_sum+=parseFloat(this) || 0;});

            } else {
              $.each(master_locations_array, function(key, value) {
                $inventory_sum += $item_inventory[value][0];
              });
              $location_sum = $item_inventory[_location_id][0];
            }

            // Build the stock inventory table
            $table_target = $item.children('.item-content').children('.item-meta');
            _buildInventoryTable($item_inventory, $table_target);

            // fix checkboxes to be enabled/ disabled depending on stock info from selected location
            $form_sizes = $table_target.children('form').children('.sizeSelector').children('ul').children('li'),
            $form_add_to_cart = $table_target.children('form').children('fieldset').children('input#add-to-cart');
            _sizeSelectionAddToCartUI($item_inventory, $location_sum, $form_add_to_cart, $form_sizes);
          });
        }
      });
    } // end if
  } // end UX for POS

  return {
    initialize: function() {

      var item_id_array;
      // loop through $products to get product_id list, make ajax call out for inventory data
      if ($('.hproduct[data-spree-product-id]').length) {
        item_id_array = [];
        $('.hproduct[data-spree-product-id]').each(function(){
          item_id_array.push($(this).data('spree-product-id'));
        });

        $.ajax({
          type: 'GET',
          data: {spree_product_ids: item_id_array},
          url: '/shop/product_stock',
          // on success, loop back through products and dump data into data attr in dom
          success: function(data,status,xhr) {
            if (data.error) {

            } else {
              var product_id,
                  inventory_hash = {},
                  data_inventory_hash,
                  $locations;

              $(data).each(function(index, item) {
                $locations = item.spree_product.locations;

                //parse the json to build our hash
                //if master variant
                if($locations[0].variants.length === 1) {
                  inventory_hash.labels = ['OS'];
                  item.spree_product.locations.map(function(l){
                    inventory_hash[l.id] = [];
                    inventory_hash[l.id].push(l.variants[0].count_on_hand);
                  });
                } else {
                  inventory_hash.labels = [];
                  $locations[0].variants.map(function(v) { // this assumes all locations have same variants
                    inventory_hash.labels.push(v.option_values);
                  });
                  $locations.map(function(loc){
                    inventory_hash[loc.id] = [];
                    loc.variants.map(function(v){
                      inventory_hash[loc.id].push(v.count_on_hand);
                    });
                  });
                }

                data_inventory_hash = JSON.stringify(inventory_hash);
                //find the relevant item and insert data-inventory
                product_id = item.spree_product.id;
                $('.hproduct[data-spree-product-id=\'' + product_id + '\']').attr('data-inventory', data_inventory_hash);
              });

              //set num_location var
              _num_locations = $(data)[0].spree_product.locations.length;

              // then init UI
              _UXforPOS();
            }
          }   // end success callback
        });
      } else { // have to init the UI anyway
        // then init just nav UI
        _buildRetailNav();
      } // end if
    } // close intitalize
  }; // end return
}());
