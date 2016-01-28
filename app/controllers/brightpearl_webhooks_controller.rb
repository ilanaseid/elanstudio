class BrightpearlWebhooksController < ApplicationController

  def product
    Brightpearl::UpdateProductOnHand.perform_async(params[:brightpearl_product_id])
    render :text=>'OK'
  end

  def order
    order=Spree::Order.find_by_brightpearl_order_id(params[:brightpearl_order_id])
    Spree::ProcessPayments.perform_async(order.id) if order
    render :text=>'OK'
  end

  def goods_out_note
    unless params[:event]=='destroyed'
      Spree::ProcessShipment.perform_async(params[:brightpearl_goods_out_note_id])
    end
    render :text=>'OK'
  end


end


#Output from order webhooks

# {"brightpearl-auth"=>"05d4b36f-017d-41b8-916e-a5364bc4193c", "Accept"=>"application/json"}
# GET https://ws-use.brightpearl.com:443/2.0.0/theline/order-service/order/100474
# --> 200 OK 2394 (232.7ms)
# {"response":[{"id":100474,"parentOrderId":0,"orderTypeCode":"SO","reference":"R688852373","orderStatus":{"orderStatusId":2,"name":"New web order"},"stockStatusCode":"SON","allocationStatusCode":"ANA","placedOn":"2013-11-22T15:11:59.000Z","createdOn":"2013-11-22T15:12:01.000Z","createdById":210,"priceListId":2,"priceModeCode":"EXC","delivery":{"shippingMethodId":0},"invoices":[{"invoiceReference":"","taxDate":"2013-11-22T00:00:00.000Z","dueDate":"2013-11-22T15:12:01.000Z"}],"currency":{"accountingCurrencyCode":"USD","orderCurrencyCode":"USD","exchangeRate":"1.000000"},"totalValue":{"net":"110.00","taxAmount":"0.00","baseNet":"110.00","baseTaxAmount":"0.00"},"assignment":{"current":{"staffOwnerContactId":0,"projectId":0,"channelId":0,"leadSourceId":0,"teamId":0}},"parties":{"customer":{"contactId":547,"addressFullName":"suzanne willis","addressLine1":"136 Kenilworth Road","addressLine2":"","addressLine3":"Ridgewood, NJ","postalCode":"07450","country":"United States","telephone":"","mobileTelephone":"","email":"","countryId":223},"delivery":{"addressFullName":"suzanne willis","companyName":"","addressLine1":"136 Kenilworth Road","addressLine2":"","addressLine3":"Ridgewood, NJ","postalCode":"07450","country":"United States","telephone":"201-612-9779","mobileTelephone":"","email":"suzanne.willis97@gmail.com","countryId":223},"billing":{"contactId":547,"addressFullName":"suzanne willis","addressLine1":"136 Kenilworth Road","addressLine2":"","addressLine3":"Ridgewood, NJ","postalCode":"07450","country":"United States","telephone":"","mobileTelephone":"","email":"","countryId":223}},"orderRows":{"1905":{"orderRowSequence":"20","productId":1000,"productName":"Shipping","quantity":{"magnitude":"1.00"},"rowValue":{"taxRate":"0.00","taxCode":"-","rowNet":{"currencyCode":"USD","value":"0.000000"},"rowTax":{"currencyCode":"USD","value":"0.00"}},"nominalCode":"4000","composition":{"bundleParent":false,"bundleChild":false,"parentOrderRowId":0}},"1904":{"orderRowSequence":"10","productId":1618,"productName":"Luxury Body Oil - 120 ML","productSku":"RODB002055045","quantity":{"magnitude":"1.00"},"rowValue":{"taxRate":"0.00","taxCode":"-","rowNet":{"currencyCode":"USD","value":"110.000000"},"rowTax":{"currencyCode":"USD","value":"0.00"}},"nominalCode":"4000","composition":{"bundleParent":false,"bundleChild":false,"parentOrderRowId":0}}},"warehouseId":2,"acknowledged":0}]}
# NameError: wrong constant name 1905
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1428:in `const_defined?'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1428:in `find_or_create_resource_for'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1278:in `block in load'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1264:in `each'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1264:in `load'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1006:in `initialize'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1406:in `new'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1406:in `block in load'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1391:in `each'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1391:in `load'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1133:in `initialize'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1058:in `new'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1058:in `instantiate_record'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1049:in `find_single'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:901:in `find'
# 	from (irb):1
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/railties-3.2.15/lib/rails/commands/console.rb:47:in `start'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/railties-3.2.15/lib/rails/commands/console.rb:8:in `start'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/railties-3.2.15/lib/rails/commands.rb:41:in `<top (required)>'
# 	from script/rails:6:in `require'
# 	from script/rails:6:in `<main>'2.0.0p247 :002 > Brightpearl::WarehouseService::Order.get '*/goods-note/goods-out/1'
# {"brightpearl-auth"=>"05d4b36f-017d-41b8-916e-a5364bc4193c", "Accept"=>"application/json"}
# GET https://ws-use.brightpearl.com:443/2.0.0/theline/warehouse-service/order/*/goods-note/goods-out/1
# --> 200 OK 15 (160.1ms)
# {"response":{}}
#  => {}
# 2.0.0p247 :003 > puts "After fulfil step"
#
#
# After fulfil step:
# 2013-11-22T19:22:17.443747+00:00 heroku[router]: at=info method=GET path=/brightpearl/webhooks/order/100474?account=theline&event=modified host=www.theline.com request_id=486d8e8853e32317a92816ccbd343337 fwd="23.20.138.6" dyno=web.1 connect=7ms service=19ms status=301 bytes=5
# 2013-11-22T19:22:17.509373+00:00 app[web.2]: Cache read: http://www.theline.com/brightpearl/webhooks/goods-out-note/825?account=theline&event=created
# 2013-11-22T19:22:17.515967+00:00 heroku[router]: at=info method=GET path=/brightpearl/webhooks/goods-out-note/825?account=theline&event=created host=www.theline.com request_id=f0cf0883630601fed037f6dd8eb1b952 fwd="23.20.138.6" dyno=web.2 connect=15ms service=11ms status=301 bytes=5
# 2013-11-22T19:22:17.505276+00:00 app[web.1]: Cache read: http://www.theline.com/brightpearl/webhooks/order/100474?account=theline&event=modified
#
#
#  => nil
# 2.0.0p247 :004 > Brightpearl::OrderService::Order.find 100474
# {"brightpearl-auth"=>"05d4b36f-017d-41b8-916e-a5364bc4193c", "Accept"=>"application/json"}
# GET https://ws-use.brightpearl.com:443/2.0.0/theline/order-service/order/100474
# --> 200 OK 2395 (237.4ms)
# {"response":[{"id":100474,"parentOrderId":0,"orderTypeCode":"SO","reference":"R688852373","orderStatus":{"orderStatusId":17,"name":"Ready to ship"},"stockStatusCode":"SOA","allocationStatusCode":"AAA","placedOn":"2013-11-22T15:11:59.000Z","createdOn":"2013-11-22T15:12:01.000Z","createdById":210,"priceListId":2,"priceModeCode":"EXC","delivery":{"shippingMethodId":0},"invoices":[{"invoiceReference":"","taxDate":"2013-11-22T00:00:00.000Z","dueDate":"2013-11-22T15:12:01.000Z"}],"currency":{"accountingCurrencyCode":"USD","orderCurrencyCode":"USD","exchangeRate":"1.000000"},"totalValue":{"net":"110.00","taxAmount":"0.00","baseNet":"110.00","baseTaxAmount":"0.00"},"assignment":{"current":{"staffOwnerContactId":0,"projectId":0,"channelId":0,"leadSourceId":0,"teamId":0}},"parties":{"customer":{"contactId":547,"addressFullName":"suzanne willis","addressLine1":"136 Kenilworth Road","addressLine2":"","addressLine3":"Ridgewood, NJ","postalCode":"07450","country":"United States","telephone":"","mobileTelephone":"","email":"","countryId":223},"delivery":{"addressFullName":"suzanne willis","companyName":"","addressLine1":"136 Kenilworth Road","addressLine2":"","addressLine3":"Ridgewood, NJ","postalCode":"07450","country":"United States","telephone":"201-612-9779","mobileTelephone":"","email":"suzanne.willis97@gmail.com","countryId":223},"billing":{"contactId":547,"addressFullName":"suzanne willis","addressLine1":"136 Kenilworth Road","addressLine2":"","addressLine3":"Ridgewood, NJ","postalCode":"07450","country":"United States","telephone":"","mobileTelephone":"","email":"","countryId":223}},"orderRows":{"1905":{"orderRowSequence":"20","productId":1000,"productName":"Shipping","quantity":{"magnitude":"1.00"},"rowValue":{"taxRate":"0.00","taxCode":"-","rowNet":{"currencyCode":"USD","value":"0.000000"},"rowTax":{"currencyCode":"USD","value":"0.00"}},"nominalCode":"4000","composition":{"bundleParent":false,"bundleChild":false,"parentOrderRowId":0}},"1904":{"orderRowSequence":"10","productId":1618,"productName":"Luxury Body Oil - 120 ML","productSku":"RODB002055045","quantity":{"magnitude":"1.00"},"rowValue":{"taxRate":"0.00","taxCode":"-","rowNet":{"currencyCode":"USD","value":"110.000000"},"rowTax":{"currencyCode":"USD","value":"0.00"}},"nominalCode":"4000","composition":{"bundleParent":false,"bundleChild":false,"parentOrderRowId":0}}},"warehouseId":2,"acknowledged":0}]}
# NameError: wrong constant name 1905
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1428:in `const_defined?'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1428:in `find_or_create_resource_for'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1278:in `block in load'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1264:in `each'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1264:in `load'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1006:in `initialize'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1406:in `new'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1406:in `block in load'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1391:in `each'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1391:in `load'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1133:in `initialize'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1058:in `new'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1058:in `instantiate_record'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1049:in `find_single'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:901:in `find'
# 	from (irb):4
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/railties-3.2.15/lib/rails/commands/console.rb:47:in `start'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/railties-3.2.15/lib/rails/commands/console.rb:8:in `start'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/railties-3.2.15/lib/rails/commands.rb:41:in `<top (required)>'
# 	from script/rails:6:in `require'
# 	from scriBrightpearl::WarehouseService::Order.get '*/goods-note/goods-out/825'
# {"brightpearl-auth"=>"05d4b36f-017d-41b8-916e-a5364bc4193c", "Accept"=>"application/json"}
# GET https://ws-use.brightpearl.com:443/2.0.0/theline/warehouse-service/order/*/goods-note/goods-out/825
# --> 200 OK 459 (140.2ms)
# {"response":{"825":{"orderId":100474,"warehouseId":2,"transfer":false,"priority":false,"status":{"shipped":false,"packed":false,"picked":false,"printed":false},"shipping":{"weight":"1.20"},"releaseDate":"2013-11-22T19:22:16.000Z","createdOn":"2013-11-22T19:22:16.000Z","createdBy":459,"orderRows":{"1904":[{"productId":1618,"quantity":1,"locationId":117}]},"sequence":1,"events":[{"occured":"2013-11-22T19:22:16.000Z","eventOwnerId":459,"eventCode":"PLA"}]}}}
#  => {"orderId"=>100474, "warehouseId"=>2, "transfer"=>false, "priority"=>false, "status"=>{"shipped"=>false, "packed"=>false, "picked"=>false, "printed"=>false}, "shipping"=>{"weight"=>"1.20"}, "releaseDate"=>"2013-11-22T19:22:16.000Z", "createdOn"=>"2013-11-22T19:22:16.000Z", "createdBy"=>459, "orderRows"=>{"1904"=>[{"productId"=>1618, "quantity"=>1, "locationId"=>117}]}, "sequence"=>1, "events"=>[{"occured"=>"2013-11-22T19:22:16.000Z", "eventOwnerId"=>459, "eventCode"=>"PLA"}]}
# 2.0.0p247 :006 > puts "after printing in brightpearl"
#
# after printing in brightpearl
#  => nil
# 2.0.0p247 :007 > puts "after printing goods out note"
# after printing goods out note
# 2013-11-22T19:23:59.242050+00:00 app[web.5]: Cache read: http://www.theline.com/brightpearl/webhooks/goods-out-note/825?account=theline&event=modified
# 2013-11-22T19:23:59.250788+00:00 heroku[router]: at=info method=GET path=/brightpearl/webhooks/goods-out-note/825?account=theline&event=modified host=www.theline.com request_id=b05bb22ffb817f49a8e982c1eefa5ea6 fwd="23.20.138.6" dyno=web.5 connect=4ms service=16ms status=301 bytes=5
#
#
#  => nil
# 2.0.0p247 :008 > Brightpearl::WarehouseService::Order.get '*/goods-note/goods-out/825'
# {"brightpearl-auth"=>"05d4b36f-017d-41b8-916e-a5364bc4193c", "Accept"=>"application/json"}
# GET https://ws-use.brightpearl.com:443/2.0.0/theline/warehouse-service/order/*/goods-note/goods-out/825
# --> 200 OK 591 (174.2ms)
# {"response":{"825":{"orderId":100474,"warehouseId":2,"transfer":false,"priority":false,"status":{"shipped":false,"packed":false,"picked":false,"printed":true,"printedOn":"2013-11-22T19:23:58.000Z","printedById":459},"shipping":{"weight":"1.20"},"releaseDate":"2013-11-22T19:22:16.000Z","createdOn":"2013-11-22T19:22:16.000Z","createdBy":459,"orderRows":{"1904":[{"productId":1618,"quantity":1,"locationId":117}]},"sequence":1,"events":[{"occured":"2013-11-22T19:22:16.000Z","eventOwnerId":459,"eventCode":"PLA"},{"occured":"2013-11-22T19:23:58.000Z","eventOwnerId":459,"eventCode":"PRI"}]}}}
#  => {"orderId"=>100474, "warehouseId"=>2, "transfer"=>false, "priority"=>false, "status"=>{"shipped"=>false, "packed"=>false, "picked"=>false, "printed"=>true, "printedOn"=>"2013-11-22T19:23:58.000Z", "printedById"=>459}, "shipping"=>{"weight"=>"1.20"}, "releaseDate"=>"2013-11-22T19:22:16.000Z", "createdOn"=>"2013-11-22T19:22:16.000Z", "createdBy"=>459, "orderRows"=>{"1904"=>[{"productId"=>1618, "quantity"=>1, "locationId"=>117}]}, "sequence"=>1, "events"=>[{"occured"=>"2013-11-22T19:22:16.000Z", "eventOwnerId"=>459, "eventCode"=>"PLA"}, {"occured"=>"2013-11-22T19:23:58.000Z", "eventOwnerId"=>459, "eventCode"=>"PRI"}]}
# 2.0.0p247 :009 > Brightpearl::WarehouseService::Order.get '*/goods-note/goods-out/825'
# {"brightpearl-auth"=>"05d4b36f-017d-41b8-916e-a5364bc4193c", "Accept"=>"application/json"}
# GET https://ws-use.brightpearl.com:443/2.0.0/theline/warehouse-service/order/*/goods-note/goods-out/825
# --> 200 OK 721 (518.1ms)
# {"response":{"825":{"orderId":100474,"warehouseId":2,"transfer":false,"priority":false,"status":{"shipped":false,"packed":false,"picked":true,"printed":true,"pickedOn":"2013-11-22T19:25:28.000Z","printedOn":"2013-11-22T19:23:58.000Z","pickedById":459,"printedById":459},"shipping":{"weight":"1.20"},"releaseDate":"2013-11-22T19:22:16.000Z","createdOn":"2013-11-22T19:22:16.000Z","createdBy":459,"orderRows":{"1904":[{"productId":1618,"quantity":1,"locationId":117}]},"sequence":1,"events":[{"occured":"2013-11-22T19:22:16.000Z","eventOwnerId":459,"eventCode":"PLA"},{"occured":"2013-11-22T19:23:58.000Z","eventOwnerId":459,"eventCode":"PRI"},{"occured":"2013-11-22T19:25:28.000Z","eventOwnerId":459,"eventCode":"PIC"}]}}}
#  => {"orderId"=>100474, "warehouseId"=>2, "transfer"=>false, "priority"=>false, "status"=>{"shipped"=>false, "packed"=>false, "picked"=>true, "printed"=>true, "pickedOn"=>"2013-11-22T19:25:28.000Z", "printedOn"=>"2013-11-22T19:23:58.000Z", "pickedById"=>459, "printedById"=>459}, "shipping"=>{"weight"=>"1.20"}, "releaseDate"=>"2013-11-22T19:22:16.000Z", "createdOn"=>"2013-11-22T19:22:16.000Z", "createdBy"=>459, "orderRows"=>{"1904"=>[{"productId"=>1618, "quantity"=>1, "locationId"=>117}]}, "sequence"=>1, "events"=>[{"occured"=>"2013-11-22T19:22:16.000Z", "eventOwnerId"=>459, "eventCode"=>"PLA"}, {"occured"=>"2013-11-22T19:23:58.000Z", "eventOwnerId"=>459, "eventCode"=>"PRI"}, {"occured"=>"2013-11-22T19:25:28.000Z", "eventOwnerId"=>459, "eventCode"=>"PIC"}]}
#
#
#
#
#
#
# last step in ship station
# 2013-11-22T19:27:18.155056+00:00 app[web.8]: Cache read: http://www.theline.com/brightpearl/webhooks/goods-out-note/825?account=theline&event=modified
# 2013-11-22T19:27:18.160699+00:00 heroku[router]: at=info method=GET path=/brightpearl/webhooks/goods-out-note/825?account=theline&event=modified host=www.theline.com request_id=b1440914ec8664ce45028175fb3b4477 fwd="23.20.138.6" dyno=web.8 connect=2ms service=7ms status=301 bytes=5
# 2013-11-22T19:27:19.210796+00:00 app[web.3]: Cache read: http://www.theline.com/brightpearl/webhooks/goods-out-note/825?account=theline&event=modified
# 2013-11-22T19:27:20.956379+00:00 app[web.1]: Cache read: http://www.theline.com/brightpearl/webhooks/order/100474?account=theline&event=modified
# 2013-11-22T19:27:18.171433+00:00 heroku[router]: at=info method=GET path=/brightpearl/webhooks/order/100474?account=theline&event=modified host=www.theline.com request_id=8bc1f160ceb77f958e17c5c5efa8646d fwd="23.20.138.6" dyno=web.1 connect=4ms service=13ms s
#
# 2.0.0p247 :010 > Brightpearl::OrderService::Order.find 100474
# {"brightpearl-auth"=>"05d4b36f-017d-41b8-916e-a5364bc4193c", "Accept"=>"application/json"}
# GET https://ws-use.brightpearl.com:443/2.0.0/theline/order-service/order/100474
# --> 200 OK 2395 (285.1ms)
# {"response":[{"id":100474,"parentOrderId":0,"orderTypeCode":"SO","reference":"R688852373","orderStatus":{"orderStatusId":17,"name":"Ready to ship"},"stockStatusCode":"SOA","allocationStatusCode":"AAA","placedOn":"2013-11-22T15:11:59.000Z","createdOn":"2013-11-22T15:12:01.000Z","createdById":210,"priceListId":2,"priceModeCode":"EXC","delivery":{"shippingMethodId":0},"invoices":[{"invoiceReference":"","taxDate":"2013-11-22T00:00:00.000Z","dueDate":"2013-11-22T15:12:01.000Z"}],"currency":{"accountingCurrencyCode":"USD","orderCurrencyCode":"USD","exchangeRate":"1.000000"},"totalValue":{"net":"110.00","taxAmount":"0.00","baseNet":"110.00","baseTaxAmount":"0.00"},"assignment":{"current":{"staffOwnerContactId":0,"projectId":0,"channelId":0,"leadSourceId":0,"teamId":0}},"parties":{"customer":{"contactId":547,"addressFullName":"suzanne willis","addressLine1":"136 Kenilworth Road","addressLine2":"","addressLine3":"Ridgewood, NJ","postalCode":"07450","country":"United States","telephone":"","mobileTelephone":"","email":"","countryId":223},"delivery":{"addressFullName":"suzanne willis","companyName":"","addressLine1":"136 Kenilworth Road","addressLine2":"","addressLine3":"Ridgewood, NJ","postalCode":"07450","country":"United States","telephone":"201-612-9779","mobileTelephone":"","email":"suzanne.willis97@gmail.com","countryId":223},"billing":{"contactId":547,"addressFullName":"suzanne willis","addressLine1":"136 Kenilworth Road","addressLine2":"","addressLine3":"Ridgewood, NJ","postalCode":"07450","country":"United States","telephone":"","mobileTelephone":"","email":"","countryId":223}},"orderRows":{"1905":{"orderRowSequence":"20","productId":1000,"productName":"Shipping","quantity":{"magnitude":"1.00"},"rowValue":{"taxRate":"0.00","taxCode":"-","rowNet":{"currencyCode":"USD","value":"0.000000"},"rowTax":{"currencyCode":"USD","value":"0.00"}},"nominalCode":"4000","composition":{"bundleParent":false,"bundleChild":false,"parentOrderRowId":0}},"1904":{"orderRowSequence":"10","productId":1618,"productName":"Luxury Body Oil - 120 ML","productSku":"RODB002055045","quantity":{"magnitude":"1.00"},"rowValue":{"taxRate":"0.00","taxCode":"-","rowNet":{"currencyCode":"USD","value":"110.000000"},"rowTax":{"currencyCode":"USD","value":"0.00"}},"nominalCode":"4000","composition":{"bundleParent":false,"bundleChild":false,"parentOrderRowId":0}}},"warehouseId":2,"acknowledged":0}]}
# NameError: wrong constant name 1905
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1428:in `const_defined?'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1428:in `find_or_create_resource_for'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1278:in `block in load'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1264:in `each'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1264:in `load'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1006:in `initialize'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1406:in `new'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1406:in `block in load'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1391:in `each'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1391:in `load'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1133:in `initialize'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1058:in `new'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1058:in `instantiate_record'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1049:in `find_single'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:901:in `find'
# 	from (irb):10
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/railties-3.2.15/lib/rails/commands/console.rb:47:in `start'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/railties-3.2.15/lib/rails/commands/console.rb:8:in `start'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/railties-3.2.15/lib/rails/commands.rb:41:in `<top (required)>'
# 	from script/rails:6:in `require'
# 	from script/rails:6:in `<main>'
#
#
#
#
# 2.0.0p247 :011 > Brightpearl::WarehouseService::Order.get '*/goods-note/goods-out/825'
# {"brightpearl-auth"=>"05d4b36f-017d-41b8-916e-a5364bc4193c", "Accept"=>"application/json"}
# GET https://ws-use.brightpearl.com:443/2.0.0/theline/warehouse-service/order/*/goods-note/goods-out/825
# --> 200 OK 1008 (504.8ms)
# {"response":{"825":{"orderId":100474,"warehouseId":2,"transfer":false,"priority":false,"status":{"shipped":true,"packed":true,"picked":true,"printed":true,"pickedOn":"2013-11-22T19:25:28.000Z","packedOn":"2013-11-22T19:35:49.000Z","shippedOn":"2013-11-22T19:35:49.000Z","printedOn":"2013-11-22T19:23:58.000Z","pickedById":459,"packedById":1,"shippedById":1,"printedById":459},"shipping":{"reference":"1Z0T13T60396221979","weight":"1.20"},"releaseDate":"2013-11-22T19:22:16.000Z","createdOn":"2013-11-22T19:22:16.000Z","createdBy":459,"orderRows":{"1904":[{"productId":1618,"quantity":1,"locationId":117}]},"sequence":1,"events":[{"occured":"2013-11-22T19:22:16.000Z","eventOwnerId":459,"eventCode":"PLA"},{"occured":"2013-11-22T19:23:58.000Z","eventOwnerId":459,"eventCode":"PRI"},{"occured":"2013-11-22T19:25:28.000Z","eventOwnerId":459,"eventCode":"PIC"},{"occured":"2013-11-22T19:35:49.000Z","eventOwnerId":1,"eventCode":"SHW"},{"occured":"2013-11-22T19:35:49.000Z","eventOwnerId":1,"eventCode":"PAC"}]}}}
#  => {"orderId"=>100474, "warehouseId"=>2, "transfer"=>false, "priority"=>false, "status"=>{"shipped"=>true, "packed"=>true, "picked"=>true, "printed"=>true, "pickedOn"=>"2013-11-22T19:25:28.000Z", "packedOn"=>"2013-11-22T19:35:49.000Z", "shippedOn"=>"2013-11-22T19:35:49.000Z", "printedOn"=>"2013-11-22T19:23:58.000Z", "pickedById"=>459, "packedById"=>1, "shippedById"=>1, "printedById"=>459}, "shipping"=>{"reference"=>"1Z0T13T60396221979", "weight"=>"1.20"}, "releaseDate"=>"2013-11-22T19:22:16.000Z", "createdOn"=>"2013-11-22T19:22:16.000Z", "createdBy"=>459, "orderRows"=>{"1904"=>[{"productId"=>1618, "quantity"=>1, "locationId"=>117}]}, "sequence"=>1, "events"=>[{"occured"=>"2013-11-22T19:22:16.000Z", "eventOwnerId"=>459, "eventCode"=>"PLA"}, {"occured"=>"2013-11-22T19:23:58.000Z", "eventOwnerId"=>459, "eventCode"=>"PRI"}, {"occured"=>"2013-11-22T19:25:28.000Z", "eventOwnerId"=>459, "eventCode"=>"PIC"}, {"occured"=>"2013-11-22T19:35:49.000Z", "eventOwnerId"=>1, "eventCode"=>"SHW"}, {"occured"=>"2013-11-22T19:35:49.000Z", "eventOwnerId"=>1, "eventCode"=>"PAC"}]}
#
#  => nil
# 2.0.0p247 :013 > Brightpearl::OrderService::Order.find 100474
# {"brightpearl-auth"=>"05d4b36f-017d-41b8-916e-a5364bc4193c", "Accept"=>"application/json"}
# GET https://ws-use.brightpearl.com:443/2.0.0/theline/order-service/order/100474
# --> 200 OK 2395 (619.7ms)
# {"response":[{"id":100474,"parentOrderId":0,"orderTypeCode":"SO","reference":"R688852373","orderStatus":{"orderStatusId":17,"name":"Ready to ship"},"stockStatusCode":"SOA","allocationStatusCode":"AAA","placedOn":"2013-11-22T15:11:59.000Z","createdOn":"2013-11-22T15:12:01.000Z","createdById":210,"priceListId":2,"priceModeCode":"EXC","delivery":{"shippingMethodId":0},"invoices":[{"invoiceReference":"","taxDate":"2013-11-22T00:00:00.000Z","dueDate":"2013-11-22T15:12:01.000Z"}],"currency":{"accountingCurrencyCode":"USD","orderCurrencyCode":"USD","exchangeRate":"1.000000"},"totalValue":{"net":"110.00","taxAmount":"0.00","baseNet":"110.00","baseTaxAmount":"0.00"},"assignment":{"current":{"staffOwnerContactId":0,"projectId":0,"channelId":0,"leadSourceId":0,"teamId":0}},"parties":{"customer":{"contactId":547,"addressFullName":"suzanne willis","addressLine1":"136 Kenilworth Road","addressLine2":"","addressLine3":"Ridgewood, NJ","postalCode":"07450","country":"United States","telephone":"","mobileTelephone":"","email":"","countryId":223},"delivery":{"addressFullName":"suzanne willis","companyName":"","addressLine1":"136 Kenilworth Road","addressLine2":"","addressLine3":"Ridgewood, NJ","postalCode":"07450","country":"United States","telephone":"201-612-9779","mobileTelephone":"","email":"suzanne.willis97@gmail.com","countryId":223},"billing":{"contactId":547,"addressFullName":"suzanne willis","addressLine1":"136 Kenilworth Road","addressLine2":"","addressLine3":"Ridgewood, NJ","postalCode":"07450","country":"United States","telephone":"","mobileTelephone":"","email":"","countryId":223}},"orderRows":{"1905":{"orderRowSequence":"20","productId":1000,"productName":"Shipping","quantity":{"magnitude":"1.00"},"rowValue":{"taxRate":"0.00","taxCode":"-","rowNet":{"currencyCode":"USD","value":"0.000000"},"rowTax":{"currencyCode":"USD","value":"0.00"}},"nominalCode":"4000","composition":{"bundleParent":false,"bundleChild":false,"parentOrderRowId":0}},"1904":{"orderRowSequence":"10","productId":1618,"productName":"Luxury Body Oil - 120 ML","productSku":"RODB002055045","quantity":{"magnitude":"1.00"},"rowValue":{"taxRate":"0.00","taxCode":"-","rowNet":{"currencyCode":"USD","value":"110.000000"},"rowTax":{"currencyCode":"USD","value":"0.00"}},"nominalCode":"4000","composition":{"bundleParent":false,"bundleChild":false,"parentOrderRowId":0}}},"warehouseId":2,"acknowledged":0}]}
# NameError: wrong constant name 1905
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1428:in `const_defined?'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1428:in `find_or_create_resource_for'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1278:in `block in load'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1264:in `each'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1264:in `load'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/activeresource-3.2.15/lib/active_resource/base.rb:1006:in `initialize'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1406:in `new'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1406:in `block in load'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1391:in `each'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1391:in `load'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1133:in `initialize'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1058:in `new'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1058:in `instantiate_record'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:1049:in `find_single'
# 	from /Users/joel/Sites/theline.com/working/theline/lib/brightpearl/base.rb:901:in `find'
# 	from (irb):13
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/railties-3.2.15/lib/rails/commands/console.rb:47:in `start'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/railties-3.2.15/lib/rails/commands/console.rb:8:in `start'
# 	from /Users/joel/.rvm/gems/ruby-2.0.0-p247/gems/railties-3.2.15/lib/rails/commands.rb:41:in `<top (required)>'
# 	from script/rails:6:in `require'
# 	from script/rai

# Brightpearl::OrderService.get('../order-status')
# {"response":[
#   {"statusId":2,"name":"New web order","orderTypeCode":"SO","sortOrder":0,"disabled":false,"visible":true,"color":"#F94424","remindAfterDays":5,"alertEmails":[],"batchProcess":false},
#   {"statusId":36,"name":"New SOHO Order","orderTypeCode":"SO","sortOrder":10,"disabled":false,"visible":false,"color":"#F58E61","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":37,"name":"New LA Order","orderTypeCode":"SO","sortOrder":20,"disabled":false,"visible":false,"color":"#FCB297","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":17,"name":"Ready to ship","orderTypeCode":"SO","sortOrder":30,"disabled":false,"visible":true,"color":"#CFFFB8","remindAfterDays":10,"alertEmails":[],"batchProcess":false},
#   {"statusId":19,"name":"Shipped!","orderTypeCode":"SO","sortOrder":40,"disabled":false,"visible":true,"color":"#085908","remindAfterDays":1,"alertEmails":[],"batchProcess":false},
#   {"statusId":33,"name":"EXCEPTION - ecom","orderTypeCode":"SO","sortOrder":50,"disabled":false,"visible":false,"color":"#24C4DB","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":32,"name":"EXCEPTION - Soho","orderTypeCode":"SO","sortOrder":60,"disabled":false,"visible":false,"color":"#5DE1F4","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":38,"name":"EXCEPTION - LA","orderTypeCode":"SO","sortOrder":70,"disabled":false,"visible":false,"color":"#B1F2FB","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":23,"name":"SPECIAL ORDER - ecom","orderTypeCode":"SO","sortOrder":80,"disabled":false,"visible":true,"color":"#FD62CE","remindAfterDays":0,"alertEmails":["Sarah@theline.com"],"batchProcess":false},
#   {"statusId":34,"name":"SPECIAL ORDER - Soho","orderTypeCode":"SO","sortOrder":90,"disabled":false,"visible":false,"color":"#F835BD","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":39,"name":"SPECIAL ORDER - LA","orderTypeCode":"SO","sortOrder":100,"disabled":false,"visible":false,"color":"#FCB5E7","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":28,"name":"SHIPS FROM VENDOR - ecom","orderTypeCode":"SO","sortOrder":110,"disabled":false,"visible":false,"color":"#BA0326","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":35,"name":"SHIPS FROM VENDOR - Soho","orderTypeCode":"SO","sortOrder":120,"disabled":false,"visible":false,"color":"#EA0B36","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":40,"name":"SHIPS FROM VENDOR - LA","orderTypeCode":"SO","sortOrder":130,"disabled":false,"visible":false,"color":"#FB5B7A","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":29,"name":"APPLY EMPLOYEE DISCOUNT","orderTypeCode":"SO","sortOrder":140,"disabled":false,"visible":false,"color":"#C1EB2D","remindAfterDays":0,"alertEmails":["ben@theline.com"],"batchProcess":false},
#   {"statusId":31,"name":"Employee Order COMPLETE","orderTypeCode":"SO","sortOrder":150,"disabled":false,"visible":false,"color":"#529A0E","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":24,"name":"CANCELLED - No Inventory Update","orderTypeCode":"SO","sortOrder":160,"disabled":false,"visible":false,"color":"#65311B","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":1,"name":"X Draft / Quote","orderTypeCode":"SO","sortOrder":170,"disabled":false,"visible":false,"color":"#E7E6E4","remindAfterDays":10,"alertEmails":[],"batchProcess":false},
#   {"statusId":3,"name":"X New phone order","orderTypeCode":"SO","sortOrder":180,"disabled":false,"visible":true,"color":"#E1DFDB","remindAfterDays":4,"alertEmails":[],"batchProcess":false},
#   {"statusId":18,"name":"X Ready to Fulfill","orderTypeCode":"SO","sortOrder":190,"disabled":false,"visible":true,"color":"#D9DBD1","remindAfterDays":5,"alertEmails":[],"batchProcess":false},
#   {"statusId":5,"name":"X Cancelled","orderTypeCode":"SO","sortOrder":200,"disabled":false,"visible":false,"color":"#D7D3D1","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":4,"name":"X Invoiced","orderTypeCode":"SO","sortOrder":210,"disabled":false,"visible":true,"color":"#D1D6D1","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":6,"name":"Pending PO","orderTypeCode":"PO","sortOrder":0,"disabled":false,"visible":false,"color":"#EEEEEE","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":7,"name":"Placed with supplier","orderTypeCode":"PO","sortOrder":10,"disabled":false,"visible":true,"color":"#AAFEFE","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":8,"name":"Products received","orderTypeCode":"PO","sortOrder":20,"disabled":false,"visible":true,"color":"#66CCCC","remindAfterDays":0,"alertEmails":["Sarah@theline.com"],"batchProcess":false},
#   {"statusId":22,"name":"Products Received II","orderTypeCode":"PO","sortOrder":30,"disabled":false,"visible":true,"color":"#616EF5","remindAfterDays":0,"alertEmails":["Sarah@theline.com"],"batchProcess":false},
#   {"statusId":25,"name":"Closed - Received in Full","orderTypeCode":"PO","sortOrder":40,"disabled":false,"visible":true,"color":"#F46E2F","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":26,"name":"CANCELLED - No Inventory Update","orderTypeCode":"PO","sortOrder":50,"disabled":false,"visible":false,"color":"#8E563E","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":9,"name":"Invoice received","orderTypeCode":"PO","sortOrder":60,"disabled":false,"visible":true,"color":"#55FF55","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":10,"name":"Sales credit","orderTypeCode":"SC","sortOrder":0,"disabled":false,"visible":false,"remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":11,"name":"Sales credit complete","orderTypeCode":"SC","sortOrder":0,"disabled":false,"visible":false,"remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":21,"name":"Cancelled","orderTypeCode":"SC","sortOrder":0,"disabled":false,"visible":false,"color":"#967E69","remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":12,"name":"Purchase credit","orderTypeCode":"PC","sortOrder":0,"disabled":false,"visible":false,"remindAfterDays":0,"alertEmails":[],"batchProcess":false},
#   {"statusId":13,"name":"Purchase credit complete","orderTypeCode":"PC","sortOrder":0,"disabled":false,"visible":false,"remindAfterDays":0,"alertEmails":[],"batchProcess":false}]}
