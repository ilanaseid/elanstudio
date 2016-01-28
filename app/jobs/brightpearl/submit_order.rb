module Brightpearl
  class SubmitOrder
    include Sidekiq::Worker

    def perform(order_id)

      if Settings.brightpearl.readonly
        logger.info "Brightpearl is set to read_only, not submitting."
        return
      end

      order=Spree::Order.find(order_id)
      logger.info "Starting order submission to Brightpearl for #{order.number}"

      if order.brightpearl_order_id.present?
        logger.debug "Order already has a brightpearl order id, checking order rows for accuracy."
        Airbrake.notify('Order Already Exists', :error_message=>"Order #{order.number} Already Has A Brightpearl ID #{order.brightpearl_order_id}")
        check_order(order)
        #raise RuntimeError, "Order #{order.number} already has an associated Brightpearl ID #{order.brightpearl_order_id}"
      else
        process_order(order)
      end

    end

    def check_order(order)
      bp_order=Brightpearl::OrderService::Order.find(order.brightpearl_order_id)
      #o.orderRows.attributes.select {|k,v| v.attributes['productId']==3197}

      order.line_items.each do |line|
        found_row=bp_order.orderRows.attributes.select {|k,v| v.attributes['productId']==line.variant.brightpearl_product_id }
        if found_row.empty?
          add_bp_product_row(order,bp_order,line)
        end
      end

      order.all_adjustments.tax.eligible.group_by(&:label).each do |label, adjustments|
        found_row=bp_order.orderRows.attributes.select {|k,v| v.attributes['productName']==label }
        if found_row.empty?
          add_bp_generic_row(order,bp_order,label,adjustments.sum(&:amount))
        end
      end

      order.adjustments.eligible.each do |adjustment|
        found_row=bp_order.orderRows.attributes.select {|k,v| v.attributes['productName']==adjustment.label }
        if found_row.empty?
          add_bp_adjustment_row(order,bp_order,adjustment)
        end
      end

      order.shipments.each do |shipment|
        found_row=bp_order.orderRows.attributes.select {|k,v| v.attributes['productName']==shipment.shipping_method.name }
        if found_row.empty?
          add_bp_shipment_row(order,bp_order,shipment)
        end
      end

#Switching these to a note, which doesn't let us enumerate them so we are just going to keep re-adding :(
      if order.retail_staff_order_detail.present?
#         found_row=bp_order.orderRows.attributes.select {|k,v| v.attributes['productName']==retail_staff_order_message(order) }
#         if found_row.empty?
          add_bp_retail_staff_order_note(order,bp_order)
#        end
      end

      if order.gift?
        found_row=bp_order.orderRows.attributes.select {|k,v| v.attributes['productName']==gift_message(order) }
        if found_row.empty?
          add_bp_gift_row(order,bp_order)
        end
      end

      logger.debug "Order is now complete."
    end

    def retail_staff_order_message(order)
      "Customer ID / Email: #{order.retail_staff_order_detail.customer_id}\nTrade Discount: #{order.retail_staff_order_detail.trade_discount}\nShipping / Packout Method: #{order.retail_staff_order_detail.shipping_method}\nInternal Comments: #{order.retail_staff_order_detail.internal_comments}"
    end

    def gift_message(order)
      "To: #{order.gift_detail.to} From: #{order.gift_detail.from} Message: #{order.gift_detail.message}"
    end

    def add_bp_product_row(order,bp_order,line)
      logger.debug "Creating order row in Brightpearl for #{line.inspect}"
      row=Brightpearl::OrderService::Row.new
      row.parent_id=bp_order.id
      row.productId=line.variant.brightpearl_product_id
      row.quantity={magnitude: line.quantity}
      row.rowValue={taxCode: '-', rowNet: {value: line.amount.to_f}, rowTax: {value: "0.00"}}
      row.save

      raise RuntimeError, "Couldn't save Brightpearl order product row for #{line.inspect}" if row.id.blank?

      create_trello_card(order,line) if line.variant.shipping_category_id==10
    end


    def add_bp_generic_row(order,bp_order,label,amount)
      logger.debug "Creating order row in Brightpearl for #{label}"
      row=Brightpearl::OrderService::Row.new
      row.parent_id=bp_order.id
      row.productName=label
      row.quantity={magnitude: "1"}
      row.rowValue={taxCode: '-', rowNet: {value: amount.to_f}, rowTax: {value: "0.00"}}
      row.save

      raise RuntimeError, "Couldn't save Brightpearl order generic row for #{label}" if row.id.blank?
    end


    def add_bp_adjustment_row(order,bp_order,adjustment)
      logger.debug "Creating order row in Brightpearl for #{adjustment.inspect}"
      row=Brightpearl::OrderService::Row.new
      row.parent_id=bp_order.id
      row.productName=adjustment.label
      row.quantity={magnitude: "1"}
      row.rowValue={taxCode: '-', rowNet: {value: adjustment.amount.to_f}, rowTax: {value: "0.00"}}
      row.save

      raise RuntimeError, "Couldn't save Brightpearl order adjustment row for #{adjustment.inspect}" if row.id.blank?
    end

    def add_bp_shipment_row(order,bp_order,shipment)
      logger.debug "Creating order row in Brightpearl for #{shipment.inspect} - #{shipment.shipping_method.inspect}"
      row=Brightpearl::OrderService::Row.new
      row.parent_id=bp_order.id
      row.productName=shipment.shipping_method.name
      row.quantity={magnitude: "1"}
      row.rowValue={taxCode: '-', rowNet: {value: shipment.cost.to_f}, rowTax: {value: "0.00"}}
      row.save

      raise RuntimeError, "Couldn't save Brightpearl order adjustment row for #{shipment.inspect}" if row.id.blank?
    end

    def add_bp_retail_staff_order_note(order,bp_order)
      logger.debug "Creating order note in Brightpearl for retail staff order detail: #{order.retail_staff_order_detail}"
      note=Brightpearl::OrderService::Note.new
      note.parent_id=bp_order.id
      note.text=retail_staff_order_message(order)
      #row.quantity={magnitude: "1"}
      #row.rowValue={taxCode: '-', rowNet: {value: "0.00"}, rowTax: {value: "0.00"}}
      note.save

      raise RuntimeError, "Couldn't save Brightpearl staff order detail note for #{order.retail_staff_order_detail}" if note.id.blank?
    end

    def add_bp_gift_row(order,bp_order)
      logger.debug "Creating order row in Brightpearl for gift detail: #{order.gift_detail}"
      row=Brightpearl::OrderService::Row.new
      row.parent_id=bp_order.id
      row.productName=gift_message(order)
      row.quantity={magnitude: "1"}
      row.rowValue={taxCode: '-', rowNet: {value: "0.00"}, rowTax: {value: "0.00"}}
      row.save

      raise RuntimeError, "Couldn't save Brightpearl gift detail row for #{order.gift_detail}" if row.id.blank?
    end

    def create_trello_card(order,line)
      card_name="#{order.number} :: #{order.ship_address.firstname} #{order.ship_address.lastname} :: #{order.completed_at} :: #{line.variant.name} :: #{line.variant.sku}"
      card_description=""
      order.ship_address.tap do |address|
        card_description=["#{address.firstname} #{address.lastname}", address.company, address.address1, address.address2, "#{address.city}, #{address.state.present? ? address.state.abbr : address.state_name}", address.zipcode, address.country.name, address.phone, (order.user ? order.user.email : order.email)].compact.join("\n")
      end
      Trello::CreateSpecialOrderCard.perform_async(card_name,card_description)
    end


    def process_order(order)
      # guest order or user order?
      if order.user
        bp_order=create_bp_user_order(order)
      else
        bp_order=create_bp_guest_order(order)
      end

      order.brightpearl_order_id=bp_order.id
      order.save
      #TODO: wrap all of this in error checking/transaction type stuff
      #TODO: lookup actual tax codes Brightpearl::AccountingService::TaxCode.all

      order.line_items.each do |line|
        add_bp_product_row(order,bp_order,line)
      end

      order.all_adjustments.tax.eligible.group_by(&:label).each do |label, adjustments|
        add_bp_generic_row(order,bp_order,label,adjustments.sum(&:amount))
      end

      order.adjustments.eligible.each do |adjustment|
        add_bp_adjustment_row(order,bp_order,adjustment)
      end

      order.shipments.each do |shipment|
        add_bp_shipment_row(order,bp_order,shipment)
      end

      if order.retail_staff_order_detail.present?
        add_bp_retail_staff_order_note(order,bp_order)
      end

      if order.gift?
        add_bp_gift_row(order,bp_order)
      end
    end

    def create_bp_user_order(order)
      user = order.user

      if user.brightpearl_contact_id.blank?
        logger.info "Creating a new contact in Brightpearl for spree user #{user.email}"

        billing_address = ''
        order.bill_address.tap do |address|
          billing_address = Brightpearl::ContactService::PostalAddress.create(addressLine1: address.address1, addressLine2: address.address2, addressLine3: "#{address.city}, #{address.state.present? ? address.state.abbr : address.state_name}" , postalCode: address.zipcode, countryIsoCode: address.country.iso3)
        end
        logger.debug "Created a new address for billing in Brightpearl #{billing_address.inspect}"

        shipping_address = ''
        order.ship_address.tap do |address|
          shipping_address = Brightpearl::ContactService::PostalAddress.create(addressLine1: address.address1, addressLine2: address.address2, addressLine3: "#{address.city}, #{address.state.present? ? address.state.abbr : address.state_name}" , postalCode: address.zipcode, countryIsoCode: address.country.iso3)
        end
        logger.debug "Created a new address for shipping in Brightpearl #{shipping_address.inspect}"

        contact = Brightpearl::ContactService::Contact.new(firstName: user.firstname, lastName: user.lastname)
        contact.postAddressIds = {DEF: billing_address.id, BIL: billing_address.id, DEL: shipping_address.id}
        contact.communication = {telephones: {PRI: order.bill_address.phone, SEC: order.ship_address.phone}, emails: {PRI: {email: user.email}} }
        contact.save

        raise RuntimeError, "Couldn't create a Brightpearl contact for order #{order.number}" if contact.id.blank?
        logger.debug "Created a new contact in Brightpearl #{contact.inspect}"

        user.brightpearl_contact_id = contact.id
        user.save!
      end
      
      bp_order = Brightpearl::OrderService::Order.new(orderTypeCode: "SO", reference: "#{order.number}-#{order.user.orders.complete.count}#{order.packaging_indication}", placedOn: order.completed_at.iso8601)
      bp_order.orderStatus = {orderStatusId: 2} #2 is new web order
      bp_order.warehouseId = order.stock_location.brightpearl_warehouse_id

      shipping_method_id = order.shipments.first.shipping_method.id

      bp_order.delivery = {shippingMethodId: (shipping_method_id==1 ? 8 : 7)} #7 is overnight, 8 is 2nd day in BP -- 1 is 2nd day and 2 is next day in spree
      bp_order.parties = {}

      bp_order.parties[:customer] = {}
      bp_order.parties[:customer].tap do |customer|
        bill_address = order.bill_address
        customer[:contactId] = user.brightpearl_contact_id
        customer[:addressFullName] = "#{bill_address.firstname} #{bill_address.lastname}"
        customer[:companyName] = "#{bill_address.company}"
        customer[:addressLine1] = bill_address.address1
        customer[:addressLine2] = bill_address.address2
        customer[:addressLine3] = "#{bill_address.city}, #{bill_address.state.present? ? bill_address.state.abbr : bill_address.state_name}"
        customer[:postalCode] = bill_address.zipcode
        customer[:countryIsoCode] = bill_address.country.iso3
        customer[:telephone] = bill_address.phone
        customer[:email] = user.email
      end

      bp_order.parties[:delivery] = {}
      bp_order.parties[:delivery].tap do |address|
        ship_address = order.ship_address
        address[:contactId] = user.brightpearl_contact_id
        address[:addressFullName] = "#{ship_address.firstname} #{ship_address.lastname}"
        address[:companyName] = "#{ship_address.company}"
        address[:addressLine1] = ship_address.address1
        address[:addressLine2] = ship_address.address2
        address[:addressLine3] = "#{ship_address.city}, #{ship_address.state.present? ? ship_address.state.abbr : ship_address.state_name}"
        address[:postalCode] = ship_address.zipcode
        address[:countryIsoCode] = ship_address.country.iso3
        address[:telephone] = ship_address.phone
        address[:email] = user.email
      end

      bp_order.parties[:billing] = {}
      bp_order.parties[:billing].tap do |address|
        bill_address = order.bill_address
        address[:contactId] = user.brightpearl_contact_id
        address[:addressFullName] = "#{bill_address.firstname} #{bill_address.lastname}"
        address[:companyName] = "#{bill_address.company}"
        address[:addressLine1] = bill_address.address1
        address[:addressLine2] = bill_address.address2
        address[:addressLine3] = "#{bill_address.city}, #{bill_address.state.present? ? bill_address.state.abbr : bill_address.state_name}"
        address[:postalCode] = bill_address.zipcode
        address[:countryIsoCode] = bill_address.country.iso3
        address[:telephone] = bill_address.phone
        address[:email] = user.email
      end

      bp_order.save
      raise RuntimeError, "Couldn't create a Brightpearl order for order #{order.number}" if bp_order.id.blank?
      logger.debug "Created a new order in Brightpearl #{bp_order.inspect}"

      bp_order
    end

    def create_bp_guest_order(order)
      # create contact
      logger.info "Creating a new contact in Brightpearl for guest user #{order.email}"

      billing_address = ''
      order.bill_address.tap do |address|
        billing_address = Brightpearl::ContactService::PostalAddress.create(addressLine1: address.address1, addressLine2: address.address2, addressLine3: "#{address.city}, #{address.state.present? ? address.state.abbr : address.state_name}" , postalCode: address.zipcode, countryIsoCode: address.country.iso3)
      end
      logger.debug "Created a new address for billing in Brightpearl #{billing_address.inspect}"

      shipping_address = ''
      order.ship_address.tap do |address|
        shipping_address = Brightpearl::ContactService::PostalAddress.create(addressLine1: address.address1, addressLine2: address.address2, addressLine3: "#{address.city}, #{address.state.present? ? address.state.abbr : address.state_name}" , postalCode: address.zipcode, countryIsoCode: address.country.iso3)
      end
      logger.debug "Created a new address for shipping in Brightpearl #{shipping_address.inspect}"

      contact = Brightpearl::ContactService::Contact.new(firstName: order.billing_address.firstname, lastName: order.billing_address.lastname)
      contact.postAddressIds = {DEF: billing_address.id, BIL: billing_address.id, DEL: shipping_address.id}
      contact.communication = {telephones: {PRI: order.bill_address.phone, SEC: order.ship_address.phone}, emails: {PRI: {email: order.email}} }
      contact.save

      raise RuntimeError, "Couldn't create a Brightpearl contact for order #{order.number}" if contact.id.blank?
      logger.debug "Created a new contact in Brightpearl #{contact.inspect}"

      # end create contact

      bp_order = Brightpearl::OrderService::Order.new(orderTypeCode: "SO", reference: "#{order.number}-#{Spree::Order.complete.where(email: order.email).count}#{order.packaging_indication}", placedOn: order.completed_at.iso8601)
      bp_order.orderStatus = {orderStatusId: 2} #2 is new web order
      bp_order.warehouseId = order.stock_location.brightpearl_warehouse_id

      shipping_method_id = order.shipments.first.shipping_method.id

      bp_order.delivery = {shippingMethodId: (shipping_method_id==1 ? 8 : 7)} #7 is overnight, 8 is 2nd day in BP -- 1 is 2nd day and 2 is next day in spree
      bp_order.parties = {}

      bp_order.parties[:customer] = {}
      bp_order.parties[:customer].tap do |customer|
        bill_address = order.bill_address
        customer[:contactId] = contact.id
        customer[:addressFullName] = "#{bill_address.firstname} #{bill_address.lastname}"
        customer[:companyName] = "#{bill_address.company}"
        customer[:addressLine1] = bill_address.address1
        customer[:addressLine2] = bill_address.address2
        customer[:addressLine3] = "#{bill_address.city}, #{bill_address.state.present? ? bill_address.state.abbr : bill_address.state_name}"
        customer[:postalCode] = bill_address.zipcode
        customer[:countryIsoCode] = bill_address.country.iso3
        customer[:telephone] = bill_address.phone
        customer[:email] = order.email
      end

      bp_order.parties[:delivery] = {}
      bp_order.parties[:delivery].tap do |address|
        ship_address = order.ship_address
        address[:contactId] = contact.id
        address[:addressFullName] = "#{ship_address.firstname} #{ship_address.lastname}"
        address[:companyName] = "#{ship_address.company}"
        address[:addressLine1] = ship_address.address1
        address[:addressLine2] = ship_address.address2
        address[:addressLine3] = "#{ship_address.city}, #{ship_address.state.present? ? ship_address.state.abbr : ship_address.state_name}"
        address[:postalCode] = ship_address.zipcode
        address[:countryIsoCode] = ship_address.country.iso3
        address[:telephone] = ship_address.phone
        address[:email] = order.email
      end

      bp_order.parties[:billing] = {}
      bp_order.parties[:billing].tap do |address|
        bill_address = order.bill_address
        address[:contactId] = contact.id
        address[:addressFullName] = "#{bill_address.firstname} #{bill_address.lastname}"
        address[:companyName] = "#{bill_address.company}"
        address[:addressLine1] = bill_address.address1
        address[:addressLine2] = bill_address.address2
        address[:addressLine3] = "#{bill_address.city}, #{bill_address.state.present? ? bill_address.state.abbr : bill_address.state_name}"
        address[:postalCode] = bill_address.zipcode
        address[:countryIsoCode] = bill_address.country.iso3
        address[:telephone] = bill_address.phone
        address[:email] = order.email
      end


      bp_order.save
      raise RuntimeError, "Couldn't create a Brightpearl order for order #{order.number}" if bp_order.id.blank?
      logger.debug "Created a new order in Brightpearl #{bp_order.inspect}"

      bp_order
    end

  end
end



# {"response"=>
#   [{"id"=>100089,
#     "parentOrderId"=>0,
#     "orderTypeCode"=>"SO",
#     "reference"=>"R636247131",
#     "orderStatus"=>{"orderStatusId"=>17, "name"=>"Ready to ship"},
#     "stockStatusCode"=>"SOA",
#     "allocationStatusCode"=>"AAA",
#     "placedOn"=>"2013-09-30T19:18:30.000Z",
#     "createdOn"=>"2013-09-30T19:18:32.000Z",
#     "createdById"=>210,
#     "priceListId"=>2,
#     "priceModeCode"=>"EXC",
#     "delivery"=>{"shippingMethodId"=>0},
#     "invoices"=>
#      [{"invoiceReference"=>"",
#        "taxDate"=>"2013-09-30T00:00:00.000Z",
#        "dueDate"=>"2013-09-30T00:00:00.000Z"}],
#     "currency"=>
#      {"accountingCurrencyCode"=>"USD",
#       "orderCurrencyCode"=>"USD",
#       "exchangeRate"=>"1.000000"},
#     "totalValue"=>
#      {"net"=>"12.42",
#       "taxAmount"=>"0.00",
#       "baseNet"=>"12.42",
#       "baseTaxAmount"=>"0.00"},
#     "assignment"=>
#      {"current"=>
#        {"staffOwnerContactId"=>0,
#         "projectId"=>0,
#         "channelId"=>0,
#         "leadSourceId"=>0,
#         "teamId"=>0}},
#     "parties"=>
#      {"customer"=>
#        {"contactId"=>294,
#         "addressFullName"=>"Joel Niedfeldt",
#         "companyName"=>"",
#         "addressLine1"=>"244 5th Ave #200",
#         "addressLine2"=>"",
#         "addressLine3"=>"New York, NY",
#         "addressLine4"=>"",
#         "postalCode"=>"10001",
#         "country"=>"United States",
#         "telephone"=>"",
#         "mobileTelephone"=>"",
#         "email"=>"joel@niedfeldt.com",
#         "countryId"=>223},
#       "delivery"=>
#        {"addressFullName"=>"Joel Niedfeldt",
#         "companyName"=>"",
#         "addressLine1"=>"244 5th Ave #200",
#         "addressLine2"=>"",
#         "addressLine3"=>"New York, NY",
#         "addressLine4"=>"",
#         "postalCode"=>"10001",
#         "country"=>"United States",
#         "telephone"=>"",
#         "mobileTelephone"=>"",
#         "email"=>"",
#         "countryId"=>223},
#       "billing"=>
#        {"contactId"=>294,
#         "addressFullName"=>"Joel Niedfeldt",
#         "companyName"=>"",
#         "addressLine1"=>"244 5th Ave #200",
#         "addressLine2"=>"",
#         "addressLine3"=>"New York, NY",
#         "addressLine4"=>"",
#         "postalCode"=>"10001",
#         "country"=>"United States",
#         "telephone"=>"",
#         "mobileTelephone"=>"",
#         "email"=>"",
#         "countryId"=>223}},
#     "orderRows"=>
#      {"488"=>
#        {"orderRowSequence"=>"30",
#         "productId"=>1000,
#         "productName"=>"New York Sales Tax 8.0%",
#         "quantity"=>{"magnitude"=>"1.00"},
#         "rowValue"=>
#          {"taxRate"=>"0.00",
#           "taxCode"=>"-",
#           "rowNet"=>{"currencyCode"=>"USD", "value"=>"0.920000"},
#           "rowTax"=>{"currencyCode"=>"USD", "value"=>"0.00"}},
#         "nominalCode"=>"4000",
#         "composition"=>
#          {"bundleParent"=>false, "bundleChild"=>false, "parentOrderRowId"=>0}},
#       "487"=>
#        {"orderRowSequence"=>"20",
#         "productId"=>1000,
#         "productName"=>"Shipping",
#         "quantity"=>{"magnitude"=>"1.00"},
#         "rowValue"=>
#          {"taxRate"=>"0.00",
#           "taxCode"=>"-",
#           "rowNet"=>{"currencyCode"=>"USD", "value"=>"0.000000"},
#           "rowTax"=>{"currencyCode"=>"USD", "value"=>"0.00"}},
#         "nominalCode"=>"4000",
#         "composition"=>
#          {"bundleParent"=>false, "bundleChild"=>false, "parentOrderRowId"=>0}},
#       "486"=>
#        {"orderRowSequence"=>"10",
#         "productId"=>1125,
#         "productName"=>"Coconut Oil - Coconut Naturel - 4 OZ",
#         "productSku"=>"MONB001081045",
#         "quantity"=>{"magnitude"=>"1.00"},
#         "rowValue"=>
#          {"taxRate"=>"0.00",
#           "taxCode"=>"-",
#           "rowNet"=>{"currencyCode"=>"USD", "value"=>"11.500000"},
#           "rowTax"=>{"currencyCode"=>"USD", "value"=>"0.00"}},
#         "nominalCode"=>"4000",
#         "composition"=>
#          {"bundleParent"=>false,
#           "bundleChild"=>false,
#           "parentOrderRowId"=>0}}},
#     "warehouseId"=>2,
#     "acknowledged"=>0}]}
