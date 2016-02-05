module Utility
  class Brightpearl

    class ProductMismatchError < RuntimeError; end
    class GroupSkuError < RuntimeError; end
    class PriceMismatchError < RuntimeError; end
    class ProductSplitError < RuntimeError; end
    #TODO: deal with stock locations for initial load

    ORDERED_OPTIONS=%w( 0
                        1
                        2
                        3
                        4
                        5
                        5.5
                        6
                        6.5
                        7
                        7.5
                        8
                        8.5
                        9
                        9.5
                        10
                        10.5
                        11
                        12
                        24
                        25
                        26
                        27
                        28
                        29
                        30
                        32
                        34
                        34.5
                        35
                        35.5
                        36
                        36.5
                        37
                        37.5
                        38
                        38.5
                        39
                        39.5
                        40
                        40.5
                        41
                        41.5
                        42
                        42.5
                        43
                        43.5
                        44
                        45
                        46
                        47
                        48
                        49
                        50
                        51
                        52
                        53
                        54
                        55
                        56
                        57
                        58
                        59
                        60
                        XXS
                        XS
                        S
                        P/S
                        M
                        M/L
                        L
                        XL
                        XXL
                        P/S
                        Queen
                        King
                        XXL
                        One size )

    def self.audit
      @audit ||= []
    end

    def self.log(message,payload={})
      puts message
      audit << [message,payload]
    end

    def self.site
      @site ||= ClearCMS::Site.find_or_create_by(:name=>'Elan Studio', :slug=>'elanstudio', :domain=>'elanstudio.com')
    end

    def self.cms_user
     return @user if @user
     @user = ClearCMS::User.where(:email=>'ilana@elanstudio.com').first
     unless @user
      @user = ClearCMS::User.create(:email=>'ilana@elanstudio.com', :base_name=>'systems', :full_name=>'Systems', :short_name=>'systems', :password=>'0p3ns3s4m3')
     end
     @user
    end

    def self.clear_cache
      @brightpearl_products=nil
      @by_name=nil
      @by_group_id=nil
      @audit=nil
      @option_types=nil
      @categories=nil
      @shipping_category=nil
      @tax_category=nil
      @cms_brands=nil
      @warehouse_mapping=nil
    end


    def self.brightpearl_products
      @brightpearl_products ||= ::Brightpearl::ProductService::Product.all_full_data
    end

    def self.brightpearl_products_by_name
      return @by_name if @by_name
      @by_name={}
      brightpearl_products.collect do |p|
        @by_name[p.productName] ||= {}
        @by_name[p.productName][p.id]=p
      end
      @by_name
    end

    def self.brightpearl_products_by_group_id
      return @by_group_id if @by_group_id
      @by_group_id={}
      brightpearl_products.collect do |p|
        product_group_id=p.productGroupId
        @by_group_id[product_group_id] ||= {}
        @by_group_id[product_group_id][p.id]=p
      end
      @by_group_id
    end

    def self.brightpearl_categories
      return @categories if @categories
      puts "Loading Brightpearl Categories"
      @categories = {}
      ::Brightpearl::ProductService::BrightpearlCategory.all.each do |category|
        @categories[category.id]={:name=>category.name,:parent_id=>category.parentId}
      end
      pp @categories
      @categories
    end

    def self.default_shipping_category
      @shipping_category ||= Spree::ShippingCategory.find(7) #Spree::ShippingCategory.first
    end

    def self.option_types
      @option_types ||= {}
    end

    def self.tax_category
      @tax_category ||= Spree::TaxCategory.first
    end

    def self.cms_brands
      @cms_brands ||= {}
    end

    def self.warehouse_mapping
      return @warehouse_mapping if @warehouse_mapping
      @warehouse_mapping={}
      ::Brightpearl::WarehouseService::Warehouse.all.each do |warehouse|
          w=Spree::StockLocation.find_by(brightpearl_warehouse_id: warehouse.id)
          @warehouse_mapping[w.id]=warehouse if w
      end
      @warehouse_mapping
    end


#     def self.delete_all
#       ClearCMS::Content.delete_all
#       Spree::Product.delete_all
#       Spree::Variant.delete_all
#     end

#     def self.full_import
#       import_brands
#       import_products
#     end

#     def self.full_destructive_import
#       delete_all
#       #setup_stock_locations
#       #Spree::StockLocation.create(:name=>'76 Greene Street', active: true)
#       #shipping_category=FactoryGirl.create(:spree_shipping_category)
#       #setup billing active_merchant
#
#       full_import
#     end

    def self.verify_product(product,variant)
    	raise ProductMismatchError, "skus don't match variant: #{variant.sku} product: #{product.identity.sku}" if variant.sku!=product.identity.sku
      raise ProductMismatchError, "product names don't match variant: #{variant.name} product: #{product.productName}" if variant.name!=product.productName
      raise ProductMismatchError, "prices don't match variant: #{variant.price.to_f} product: #{product.price.to_f}" if variant.price.to_f!=product.price.to_f
      #check brightpearl id, brand id, product group id
      #Product mismatch prices don't match variant: 10.0 product: 0.0
      #Product mismatch product names don't match variant: Vintage Cocktails by Brian Van Flandern product: Vintage Cocktails
      #check for other products with same name
      #check for other products with partial sku
      #check for variant counts based on products grouped by name
    end

    def self.possible_matches(product)
      product_sku=(product.identity.sku ? product.identity.sku[0..-4] : '')
      matches = []
      matches += Spree::Product.joins(:variants).where('name like ? OR spree_variants.sku like ?',"#{product.productName}%", "#{product_sku}%").uniq.to_a
      matches += Spree::Variant.where('sku like ?', "#{product_sku}%").uniq.to_a
      matches
    end

    def self.possible_group_matches(product_group_name, product_group_products)
      group_sku=nil
      group_id=nil
      product_group_products.each do |id,product|
        if group_sku
          product_style_sku=product.identity.sku[0..-4]
          raise GroupSkuError, "Group sku was #{group_sku} and product style sku was #{product_style_sku} for product named #{product_group_name}" if product_style_sku!=group_sku
        else
          group_id=product.productGroupId
          group_sku=product.identity.sku[0..-4]
        end
      end
      matches = []
      matches += Spree::Product.joins(:variants).where('name like ? OR spree_variants.sku like ?',"#{product_group_name}%", "#{group_sku}%").uniq.to_a
      matches += Spree::Variant.where('sku like ?',"#{group_sku}%").uniq.to_a
      matches += Product.where(brightpearl_sku: /#{group_sku}/).or(brightpearl_product_group_id: group_id).to_a
      matches
    end



#     def self.import_brands(options={})
#       Brand.destroy_all if options[:destroy]
#
#       ::Brightpearl::ProductService::Brand.all.each do |brand|
#         b=Brand.new(title: brand.name,
#           subtitle: brand.name,
#           basename: brand.name.parameterize.underscore,
#           brightpearl_brand_id: brand.id,
#           tags: brand.name,
#           categories: brand.name,
#           author_id: cms_user.id,
#           site_id: site.id)
#         b.content_blocks.build(type: 'raw')
#         b.save
#       end
#     end

    def self.sync_warehouses(options={})
      ::Brightpearl::WarehouseService::Warehouse.all.each do |warehouse|
        w=Spree::StockLocation.find_or_initialize_by(brightpearl_warehouse_id: warehouse.id)
        w.assign_attributes(
          name: warehouse.name
        )

        w.save

        warehouse_mapping[w.id]=warehouse

      end
    end


    def self.sync_brands(options={})
      ::Brightpearl::ProductService::Brand.all.each do |brand|
        b=Brand.find_or_initialize_by(brightpearl_brand_id: brand.id)

        b.assign_attributes(title: brand.name,
          subtitle: brand.name,
          brightpearl_brand_id: brand.id,
          tags: brand.name,
          categories: brand.name,
          author_id: cms_user.id,
          site_id: site.id)

        unless b.persisted?
          b.basename = brand.name.parameterize.underscore
          b.content_blocks.build(type: 'raw')
        end

        b.save
      end

    end

    def self.sync_products
      #Need to do this (sync brands) first so we have them loaded for the associations in cms products
      sync_warehouses
      sync_brands

      brightpearl_products.each do |brightpearl_product|
        if spree_variant=Spree::Variant.where(brightpearl_product_id: brightpearl_product.id).first  #not a new variant, but might be a new product if it was split in brightpearl
          if spree_variant.brightpearl_product_group_id==brightpearl_product.productGroupId #check to see if brightpearl_group_id is the same
            #if it is, great, let's update all of the variants details (it's safe to update the product name of the variant also)
            update_variant(spree_variant,brightpearl_product)
          else #if it isn't, then we've got either all variants moving to a new group, check for that or a new product to move this variant to because it was split off of the main one or became a master??
            #check to see if all of the existing spree variants are covered in the new group, if so, ok to update
            #spree_group_variants = Spree::Variant.where(brightpearl_product_group_id: spree_variant.brightpearl_product_group_id)
            spree_group_variants = spree_variant.product.variants
            group_ids=spree_group_variants.map(&:brightpearl_product_id) # get all of the brightpearl ids from the previous group id
            remaining_ids = group_ids - Utility::Brightpearl.brightpearl_products_by_group_id[brightpearl_product.productGroupId].keys # subtract the current group ids from those previous ones
            if remaining_ids.blank? #all of the previous bp product ids are in the new group, let's change it over
              update_variant(spree_variant,brightpearl_product)
            else
              # seems to be a split situation?? #TODO
              raise ProductSplitError, "There are remaining IDs in a change involving differing group IDs for Brightpearl ID #{brightpearl_product.id}: #{brightpearl_product.productName} and Spree variant #{spree_variant.id} with product name #{spree_variant.name}"
            end

            #move variant to a new product
          end
        else #new product or variant
          if brightpearl_products_by_name[brightpearl_product.productName].count > 1 #see if there are more brightpearl variants by same name
#TODO: what do we do when it was a single product and then had variants added
            if spree_related_variant=Spree::Variant.where(brightpearl_product_group_id: brightpearl_product.productGroupId).first #see if there are spree product/variants by brightpearl_product_group_id, we already know it shouldn't be ID=0 because the name group > 1
              create_variant(spree_related_variant.product,brightpearl_product)
            else #else if none of them exist, create the product and then all of the variants will be created as we loop through
              create_product(brightpearl_product)
            end
          else #totally new product with one master variant
            create_product(brightpearl_product)
          end
        end
      end

      check_stock_levels

      #TODO: remove stuff that is not sold/published from spree


#       brightpearl_products_by_name.each do |product_group_name, product_group_products|
#         if possible_group_matches(product_group_name,product_group_products).any?
#           log('Doing nothing, possible group matches.', :product_group_name=>product_group_name, :product_group_products=>product_group_products)
#         else
#           spree_product=nil
#           product_group_products.each do |id,product|
#             if spree_product
#               create_product_variant(spree_product,product)
#             else
#               spree_product = create_product(product)
#             end
#           end
#         end
#       end


        #check group skus for sanity, style should match
#       load by name
#       look for matching product by name (or best match logic)
#         if found, check variants count and bp ids
#           if error, raise error on name mismatch
#           else update in cms
#         else
#           create a new one, making sure its unique
#           set stock levels
#         end


        #look for set stock levels/movements
        #look for price changes

    end





#     def self.update_variant_details
#       brightpearl_products.each do |product|
#         product_name=product.productName
#         variant=Spree::Variant.where(brightpearl_product_id: product.id).first
#         product_group_id=product.productGroupId
#
#         if variant
#           if variant.brightpearl_product_group_id==product_group_id #Ok to update sku or brand, only doing sku right now
#             puts "variant sku", variant.sku
#             variant.sku=product.identity.sku
#             #TODO: really need to get a handle on these changes, need to figure out how BP is changing group ids
#             puts "product name", variant.product.name
#             variant.product.name=product_name
#             #variant.brightpearl_product_group_id=product_group_id #Be sure to change the product group so we can detect future SPLITS!
#             cms_content=Product.find_by(spree_product_id: variant.product.id)
#             puts "cms content", cms_content.title
#             cms_content.title=product_name
#             cms_content.subtitle=product_name
#             cms_content.basename=product_name.parameterize.underscore
#             product_categories=product.salesChannels.first.categories.collect {|cat| brightpearl_categories[cat.categoryCode.to_i].strip }
#             product_categories.compact!
#             cms_content.categories=product_categories + [cms_content.brand.title]
#             cms_content.save
#             #TODO: add in special delivery for this
#
#           elsif brightpearl_products_by_group_id[variant.brightpearl_product_group_id].nil? #Ok to update because previous group is gone, this is not a variant SPLIT
#             puts "product name", variant.product.name
#             variant.product.name=product_name
#             variant.brightpearl_product_group_id=product_group_id #Be sure to change the product group so we can detect future SPLITS!
#             cms_content=Product.find_by(spree_product_id: variant.product.id)
#             puts "cms content", cms_content.title
#             cms_content.title=product_name
#             cms_content.subtitle=product_name
#             cms_content.basename=product_name.parameterize.underscore
#             product_categories=product.salesChannels.first.categories.collect {|cat| brightpearl_categories[cat.categoryCode.to_i].strip }
#             product_categories.compact!
#             cms_content.categories=product_categories + [cms_content.brand.title]
#             cms_content.save
#           end
#
#           variant.save
#           variant.product.save
#
#         else
#           log "Can't find variant or product group id doesn't match.", :product=>product
#         end
#       end
#     end




    def self.clear_variant_links
      #wishlist
      #notify_me
      #orders/order_rows
    end

    def self.clear_deleted
      Spree::Variant.only_deleted.delete_all
      Spree::Product.only_deleted.delete_all
    end


    def self.sanity_check

# irb(main):009:0> Spree::Variant.where(brightpearl_product_id: nil).where(is_master: true).count
#    (2.3ms)  SELECT COUNT(*) FROM "spree_variants" WHERE "spree_variants"."deleted_at" IS NULL AND "spree_variants"."brightpearl_product_id" IS NULL AND "spree_variants"."is_master" = 't'
# => 101

#  Utility::Brightpearl.brightpearl_products_by_name.each do |k,v|
#   spree_product=Spree::Product.find_by_name(k)
#   puts k
#   puts v.count, spree_product.variants.count
#   puts '-------------'
#  end


# Utility::Brightpearl.brightpearl_products.each do |p|
# spree_variant=Spree::Variant.where(sku: p.identity.sku).first
# if spree_variant
# puts "MATCH",spree_variant.inspect,p.id
# else
# puts "NO MATCH",p.id, p.identity.sku
# end
# end

# 2.0.0p247 :002 > Spree::Variant.count
#    (0.4ms)  SELECT COUNT(*) FROM "spree_variants" WHERE "spree_variants"."deleted_at" IS NULL
#  => 911
# 2.0.0p247 :003 > Utility::Brightpearl.brightpearl_products.count
#  => 810
# 2.0.0p247 :004 > Utility::Brightpearl.brightpearl_products_by_name.count
#  => 292
#Spree::Product.all.select {|p| p.variants.count==0
#
#Spree::Variant.group(:sku).count.select {|k,v| v>1}
# 2.0.0p247 :025 > dups=_
#  => {"3X1F001102048"=>2, "3X1F002003048"=>2, "CHRF001016002"=>2, "CHRF003013002"=>2, "CHRF004003002"=>2, "CHRF004072002"=>2, "CHRF005016002"=>2, "CHRF006058002"=>2, "CHRF008025002"=>2, "JWAF004060008"=>2, "JWAF005006008"=>2, "JWAF009008008"=>2, "JWAF010008008"=>2, "NEWF001027006"=>2, "NEWF002070006"=>2, "NEWF003003006"=>2, "NEWF003009006"=>2, "PALF001053020"=>2, "PALF002053020"=>2, "PALF003053020"=>2, "PALF004010020"=>2, "PALF005053020"=>2, "PALF006010020"=>2, "PALF007053020"=>2, "PALF008010020"=>2, "PALF009044020"=>2, "PROP001003001"=>2, "PROP001012001"=>2, "PROP002074001"=>2, "PROP003003001"=>2, "PROP004074001"=>2, "PROP005050035"=>2, "PROP006011035"=>2, "PROP006012035"=>2, "PROP007011035"=>2, "PROP008011035"=>2, "PROP008012035"=>2, "PROP009003035"=>2, "PROP009012035"=>2, "PROP009074035"=>2, "PROP010050035"=>2, "PROP011003035"=>2, "PROP011012035"=>2, "PROP011041035"=>2, "PROP011074035"=>2, "PROP012050035"=>2, "PROP013003035"=>2, "PROP014074035"=>2, "PROP015003035"=>2, "PROP015074035"=>2, "RKRF001002021"=>2, "RKRF002026021"=>2, "RKRF004003035"=>2, "RKRF005056035"=>2, "RKRF006068035"=>2, "RKRF007050001"=>2, "RKRF008075021"=>2, "RKRF009050001"=>2, "RKRF012003021"=>2, "RKRF013042001"=>2, "RKRF013068001"=>2, "RKRF014042001"=>2, "RKRF015052044"=>2, "RKRF016075021"=>2, "RKRF017057021"=>2, "RKRF018078021"=>2, "RKRF019003021"=>2, "RKRF020003021"=>2, "RKRF021056021"=>2, "RKRF022078001"=>2, "RKRF024077035"=>2, "RKRF025003021"=>2, "RKRF026065021"=>2, "RKRF027003001"=>2, "RKRF028050001"=>2, "VINF001048035"=>2, "VINF002021035"=>2, "VINF003003035"=>2, "VINF003029035"=>2, "VINF003074035"=>2, "VINF004015035"=>2, "VINF004028035"=>2, "VINF005003035"=>2, "VINF006041035"=>2, "VINF007021001"=>2, "VINF009003035"=>2, "VINF009021035"=>2}
# 2.0.0p247 :026 > dups.count
#  => 87
    end

    def self.random_id
      (Time.now - Time.parse('2013-10-11')).to_i * SecureRandom.random_number(1000)
    end

    def self.fake_product_id(current_id)
      if(current_id && current_id > 99999)
        return current_id
      else
        @last_id ||= Spree::Variant.maximum(:brightpearl_product_id)
        @last_id += 1
        return @last_id
      end
    end

    def self.set_variant_fields(spree_variant,brightpearl_product,brightpearl_variant=nil)
      # hack fix please remove #
      # return false if brightpearl_product.sku == "MLMH004055045"
      # end hack #

      product_group_id=brightpearl_product.productGroupId

      if brightpearl_variant
        option_choice = option_types[brightpearl_variant.optionName] ? option_types[brightpearl_variant.optionName] : (option_types[brightpearl_variant.optionName]=Spree::OptionType.find_or_create_by(name: brightpearl_variant.optionName, presentation: brightpearl_variant.optionName))
        option_value = option_choice.option_values.find_or_create_by(name: brightpearl_variant.optionValue, presentation: brightpearl_variant.optionValue)

        #spree_variant.option_values.delete_all #let's not delete them here because if this happens outside of a transaction or in the middle of a failure, we'll have missing option values on the site

        unless spree_variant.option_values.include? option_value
          #let's delete them here, so we don't end up with multiple option values
          spree_variant.option_values.delete_all
          spree_variant.option_values << option_value
        end

        spree_variant.position = ORDERED_OPTIONS.index(option_value.presentation)

        #Add option types to the product so it knows about them in the Admin UI
        unless spree_variant.product.option_types.include? option_choice
          spree_variant.product.option_types << option_choice
        end
      end

      previous_price = spree_variant.price

      spree_variant.price=(brightpearl_product.sale_price ? brightpearl_product.sale_price : brightpearl_product.price)
      spree_variant.sku=brightpearl_product.sku
      spree_variant.brightpearl_product_id=brightpearl_product.id
      spree_variant.brightpearl_brand_id=brightpearl_product.brandId
      spree_variant.brightpearl_product_group_id=product_group_id

      if !spree_variant.is_master?
        master=spree_variant.product.master
        master.sku=brightpearl_product.groupSku #removes last 3 digits from sku (size/variant portion)
        master.brightpearl_brand_id=brightpearl_product.brandId
        master.brightpearl_product_group_id=product_group_id
        master.brightpearl_product_id=fake_product_id(master.brightpearl_product_id) #hack for validation, TODO: find another number
        master_previous_price=master.price
        master.price=(brightpearl_product.sale_price ? brightpearl_product.sale_price : brightpearl_product.price)

        # debugging code #
        if !master.valid?
          Airbrake.notify(error_message: "Something went wrong with BP variant import: #{master.inspect}, BP sync is trying to import from this brightpearl object: #{brightpearl_product.inspect}. Here are validation errors: #{master.errors.messages.inspect}")
        end
        # end debugging code #

        master.save! if (master.changed? || master_previous_price!=master.price)
      end

      ### Update product details
#       if brightpearl_product.custom_field('PCF_SHIPPING') && brightpearl_product.custom_field('PCF_SHIPPING').value=='Special Delivery'
#         special_delivery=true
#       else
#         special_delivery=false
#       end

        ## Update product details
      if brightpearl_product.custom_field('PCF_ELIGIBLE').nil? || brightpearl_product.custom_field('PCF_ELIGIBLE') #Eligible for return, can be unset or true, and is then not final sale
        final_sale=false
      else
        final_sale=true
      end

      brand=(cms_brands[brightpearl_product.brandId] ||= Brand.find_by(brightpearl_brand_id: brightpearl_product.brandId))

      product_categories=brightpearl_product.salesChannels.first.categories.collect {|cat| build_category(cat.categoryCode.to_i) }
      product_categories.compact!
      product_categories.flatten!
      product_categories=product_categories + [brand.title]

      #TODO: this would combine cms and bp categories, but doesn't seem like the right thing to do right now...would make it very hard to clear out mistakes/changes
      #product_categories=product_categories + (spree_variant.product.cms_product.categories || [])

      product_categories.uniq!


      spree_variant.product.final_sale=final_sale
      spree_variant.product.name=brightpearl_product.productName
      spree_variant.product.shipping_category_id=find_shipping_category_id(brightpearl_product)
      spree_variant.product.categories=product_categories.join(', ') if product_categories.present?
      spree_variant.product.cms_product_attributes = {
        categories: product_categories,
        final_sale: final_sale
      }

      #TODO: Hack. Migrate to proper switching of option_type and option_value on PDP instead of using 'size' and overriding the label for 'size'.
      spree_variant.product.cms_product_attributes[:option_label_override] = brightpearl_product.custom_field('PCF_VARIANTL').value if brightpearl_product.custom_field('PCF_VARIANTL')

      spree_variant.product.save! if spree_variant.product.changed?

      set_stock_levels = spree_variant.new_record? ? true : false

      # debugging code #
      if !spree_variant.valid?
        Airbrake.notify(error_message: "Something went wrong with BP variant import: #{spree_variant.inspect}, BP sync is trying to import from this brightpearl object: #{brightpearl_product.inspect}. Here are validation errors: #{spree_variant.errors.messages.inspect}")
      end
      # end debugging code #

      spree_variant.save! if (spree_variant.changed? || previous_price!=spree_variant.price)

      if previous_price!=spree_variant.price
        spree_variant.product.cms_product.update_attributes(updated_at: Time.now)
      end

      if brightpearl_product.sale_price
        cms_product=spree_variant.product.cms_product
        cms_product.original_price=brightpearl_product.price
        cms_product.tags << "Sale" unless cms_product.tags.include? "Sale"
        cms_product.save! if cms_product.changed?
      end

      if set_stock_levels && brightpearl_product.availability #don't set stock levels for items that are already persisted/could look at only published items also
        spree_variant.stock_items.each do |stock_item|
          #stock_item.stock_movements.create(:quantity=>product.on_hand)
          warehouse=warehouse_mapping[stock_item.stock_location_id]
          stock_item.set_count_on_hand(brightpearl_product.warehouse_on_hand(warehouse.id))
        end
      end

    end


    def self.create_product(p)
      puts "Creating product: #{p.productName} with BP ID: #{p.id}"
      product_name=p.productName
      product_group_id=p.productGroupId
      brand=(cms_brands[p.brandId] ||= Brand.find_by(brightpearl_brand_id: p.brandId))

      #Note: Default is
      if p.custom_field('PCF_ELIGIBLE').nil? || p.custom_field('PCF_ELIGIBLE') #Eligible for return, can be unset or true, and is then not final sale
        final_sale=false
      else
        final_sale=true
      end


#       if p.custom_field('PCF_SHIPPING') && p.custom_field('PCF_SHIPPING').value=='Special Delivery'
#         special_delivery=true
#       else
#         special_delivery=false
#       end

      product_categories=p.salesChannels.first.categories.collect {|cat| build_category(cat.categoryCode.to_i) }
      product_categories.compact!
      product_categories.flatten!
      product_categories=product_categories + [brand.title]

      #TODO: this would combine cms and bp categories, but doesn't seem like the right thing to do right now...would make it very hard to clear out mistakes/changes
      #product_categories=product_categories + (spree_variant.product.cms_product.categories || [])

      product_categories.uniq!



      #TODO: put some validations on the model level also (sku unique, name unique, etc)
      product=Spree::Product.new(name: product_name, sku: p.groupSku) #, option_types: [size_option])
      product.shipping_category_id=find_shipping_category_id(p)
      product.tax_category_id=tax_category.id
      product.available_on=Time.now
      product.price=p.price
      product.brightpearl_product_group_id=product_group_id
      product.brightpearl_brand_id=p.brandId
      product.brightpearl_product_id=fake_product_id(product.brightpearl_product_id) #have to do this to get master variant to save properly, also not properly rolling back on master variant failure since it's calling just master.save
      product.final_sale=final_sale

      product.categories=product_categories.join(', ') if product_categories.present?

      product.cms_product_attributes = {
        tags: product_categories,
        categories: product_categories,
        author_id: cms_user.id,
        site_id: site.id,
        final_sale: final_sale
        #special_delivery: special_delivery
      }

      #TODO: Hack. Migrate to proper switching of option_type and option_value on PDP instead of using 'size' and overriding the label for 'size'.
      product.cms_product_attributes[:option_label_override] = p.custom_field('PCF_VARIANTL').value if p.custom_field('PCF_VARIANTL')

      # debugging code #
      if !product.valid?
        Airbrake.notify(error_message: "Something went wrong with BP product import: #{product.inspect}, BP sync is trying to import from this brightpearl object: #{p.inspect}. Here are validation errors: #{product.errors.messages.inspect}")
      end
      # end debugging code #
      product.save!

      create_variant(product,p) #master or variant is determined here

      product
    end

#     def self.set_special_cms_fields(spree_product,brightpearl_product)
#       product_categories=brightpearl_product.salesChannels.first.categories.collect {|cat| brightpearl_categories[cat.categoryCode.to_i]}
#       product_categories.compact!
#
#       #TODO: could find or create brand in this step
#       brand=Brand.find_by(brightpearl_brand_id: brightpearl_product.brandId)
#
#       #TODO: add in special delivery!!!!
#       #TODO: wrap this whole thing in a transaction so we don't end up with products that aren't in the CMS?
#       cms_product=spree_product.cms_product
#
#       #merge this
#       #cms_product.tags=product_categories + [brand.title]
#       cms_product.categories=product_categories + [brand.title]
#
#       cms_product.save!
#     end

    def self.update_variant(spree_variant, brightpearl_product)
      if brightpearl_product.respond_to?(:variations) #product has variations, not a master product
        brightpearl_product.variations.each do |brightpearl_variant|
        #TODO: This should probably only build one spree variant with multiple options if we ever get into that...
          set_variant_fields(spree_variant,brightpearl_product,brightpearl_variant)
        end
      else #product doesn't have variations, it IS A MASTER

        #check against spree product to make sure it didn't previously have variants
        if spree_variant.product.variants(true).any?
          if spree_variant.product.variants(true).count > 1
            raise ProductMismatchError, "Brightpearl says this product does not have variants, but it appears it previously did (and had more than one so was not an issue of None or One Size): #{spree_variant.inspect}"
          else
            puts 'Product used to have variants!!  Removing master variant and making old "variation" the master instead.'
            spree_variant.product.master.destroy!
            spree_variant.option_values.delete_all
            spree_variant.is_master=true
            spree_variant.save
          end
        end

        set_variant_fields(spree_variant, brightpearl_product)
      end
    end



    def self.create_variant(spree_product, brightpearl_product)

      if brightpearl_product.respond_to?(:variations) #product has variations, not a master product
        brightpearl_product.variations.each do |brightpearl_variant|
        #TODO: This should probably only build one spree variant with multiple options if we ever get into that...
          set_variant_fields(spree_product.variants.build,brightpearl_product,brightpearl_variant)
        end
      else #product doesn't have variations, it IS A MASTER
        set_variant_fields(spree_product.master, brightpearl_product)
      end
    end



    def self.build_category(category_id)
      bp_category=brightpearl_categories[category_id]
      if bp_category[:parent_id]==0
        return bp_category[:name]
      else
        return [bp_category[:name], build_category(bp_category[:parent_id])]
      end
    end






#     def self.import_products(options={})
#       Product.destroy_all if options[:destroy]
#
#       categories = brightpearl_categories
#
#       option_types={}
#
#       #TODO: set this based on dropship?
#       shipping_category=Spree::ShippingCategory.first
#       #shipping_category=FactoryGirl.create(:spree_shipping_category)
#
#       product_groups={}
#       ::Brightpearl::ProductService::Product.all.each do |p|
#         product_name=p.productName
#         if product_groups[product_name].nil?
#           product=Spree::Product.new(name: product_name, sku: p.identity.sku, permalink: product_name.parameterize.underscore) #, option_types: [size_option])
#           product.shipping_category_id=shipping_category.id
#           product.available_on=Time.now
#           product.price=p.price
#           product.save
#
#           if p.respond_to?(:variations)
#             p.variations.each do |variant|
#               option_choice = option_types[variant.optionName] ? option_types[variant.optionName] : (option_types[variant.optionName]=Spree::OptionType.find_or_create_by_name_and_presentation(variant.optionName, variant.optionName))
#               option_value = option_choice.option_values.find_or_create_by_name_and_presentation(variant.optionValue, variant.optionValue)
#               product.master.option_values << option_value
#             end
#           end
#
#           product_group_id=p.productGroupId
#
#           product_categories=p.salesChannels.first.categories.collect {|cat| categories[cat.categoryCode.to_i]}
#           product_categories.compact!
#           brand=Brand.find_by(brightpearl_brand_id: p.brandId)
#           cms_product=Product.new(site_id: site.id,
#             author_id: cms_user.id,
#             title: product.name,
#             subtitle: product.name,
#             basename: product.name.parameterize.underscore,
#             tags: product_categories + [brand.title],
#             categories: product_categories + [brand.title],
#             brand_id: brand.id,
#             brightpearl_product_group_id: product_group_id,
#             brightpearl_brand_id: p.brandId,
#             brightpearl_sku: p.identity.sku,
#             spree_product_id: product.id) #TBD spree product id
#           cms_product.content_blocks.build(type: 'raw')
#           cms_product.save
#           product_groups[product_name]=product.id
#         else
#           product=Spree::Product.find(product_groups[product_name])
#           if p.respond_to?(:variations)
#             p.variations.each do |variant|
#               option_choice = option_types[variant.optionName] ? option_types[variant.optionName] : (option_types[variant.optionName]=Spree::OptionType.find_or_create_by_name_and_presentation(variant.optionName, variant.optionName))
#               option_value = option_choice.option_values.find_or_create_by_name_and_presentation(variant.optionValue, variant.optionValue)
#               variant=product.variants.build(sku: p.identity.sku)
#               variant.option_values << option_value
#               variant.save
#             end
#           end
#         end
#       end
#
# #      #Randomize stock levels/movements
# #       Spree::StockItem.all.each do |stock_item|
# #         stock_level=Random.rand(2).to_i
# #         #product.stock_items.first.stock_movements.create(:quantity=>stock_level)
# #         stock_item.stock_movements.create(:quantity=>stock_level)
# #       end
#
#     end


    def self.correlate_products
      not_in_brightpearl=[]
      not_in_spree=[]
      brightpearl_products_by_name.each do |k,v|
        if Spree::Product.where('name=?',k).count == 0
          not_in_spree << k
        end
      end

      Spree::Product.all.each do |product|
        if brightpearl_products_by_name.assoc(product.name).nil?
          not_in_brightpearl << product.name
        end
      end

      puts "Not in Spree"
      not_in_spree.each {|p| puts p}
      puts "--------"

      puts "Not in Brightpearl"
      not_in_brightpearl.each {|p| puts p }
      puts "--------"

      #TODO: correlate CMS

    end

    def self.unfulfilled_order_list
      #"orderStatusNames":{"1":"Draft / Quote","19":"Shipped!","2":"New web order","18":"Ready to Fulfill","5":"Cancelled"}
      #r=::Brightpearl::OrderService::OrderSearch.get('?orderStatusId=1')
      #r=::Brightpearl::OrderService::OrderSearch.get('?orderTypeId=1&orderStockStatusId=1&orderStatusId=2')
      #r=::Brightpearl::OrderService::OrderSearch.get('?orderTypeId=1&orderStockStatusId=1&orderStatusId=19&orderStatusId=2&sort=createdOn%7CDESC')

      null=nil #needed to response the null in the results for nil

      puts "Getting all unfulfilled orders..."
      all_unfulfilled_orders=::Brightpearl::OrderService::OrderSearch.get('?orderTypeId=1&orderStockStatusId=1')["response"]["results"]
      puts "Unfulfilled orders: #{all_unfulfilled_orders}"

      puts "Getting draft unfulfilled orders..."
      draft_unfulfilled_orders=::Brightpearl::OrderService::OrderSearch.get('?orderTypeId=1&orderStockStatusId=1&orderStatusId=1')["response"]["results"]
      puts "Draft unfulfilled orders: #{draft_unfulfilled_orders}"

      puts "Getting cancelled unfulfilled orders count"
      cancelled_unfulfilled_orders=::Brightpearl::OrderService::OrderSearch.get('?orderTypeId=1&orderStockStatusId=1&orderStatusId=5')["response"]["results"]
      puts "Cancelled unfulfilled orders: #{cancelled_unfulfilled_orders}"

      unfulfilled_orders = (all_unfulfilled_orders - draft_unfulfilled_orders - cancelled_unfulfilled_orders) || []
      puts "All unfulfilled orders (excluding drafts and cancelled): #{unfulfilled_orders}"

      return unfulfilled_orders
    end


    def self.check_stock_levels
      unfulfilled_orders = unfulfilled_order_list
      if unfulfilled_orders.empty?
        puts "Resetting stock levels because BP says all orders are fulfilled."
        clear_cache
        reset_stock_levels
      else
        puts "Couldn't reset stock because there are unfulfilled orders in BP"
        #SystemMailer.general('retailalerts@elanstudio.com', "Stock Levels Can't Sync Due to Open Orders", "The following orders are preventing stock syncing: #{unfulfilled_orders.inspect}").deliver
        pp unfulfilled_orders.inspect
      end
    end


    def self.reset_stock_levels

      #TODO: to reset stock levels, stock items need to be set to 0 first otherwise it's additive/subtractive or :adjust_count_on_hand, :set_count_on_hand
      brightpearl_products.each do |product|
        #spree_variant=Spree::Variant.find_by_sku(product.identity.sku)
        spree_variant=Spree::Variant.find_by_brightpearl_product_id(product.id)

        if spree_variant && product.availability
          spree_variant.stock_items.each do |stock_item|
            #stock_item.stock_movements.create(:quantity=>product.on_hand)
            warehouse=warehouse_mapping[stock_item.stock_location_id]


            if !(stock_item.count_on_hand==product.warehouse_on_hand(warehouse.id))
              stock_item.set_count_on_hand(product.warehouse_on_hand(warehouse.id))
              # Moved this logic directly into after_save callback in Spree::StockItem
#               system_flag=(spree_variant.product.total_on_hand==0 ? 'Sold Out' : nil)
#               spree_variant.product.cms_product.update_attributes(updated_at: Time.now, system_flag: system_flag)
            end
          end
        else
          log "Couldn't find spree variant for #{product.identity.sku}", :product=>product
        end
      end
    end

    def self.correlate_stock_levels
      wrong_stock=[]
      brightpearl_products.each do |product|
        #spree_variant=Spree::Variant.find_by_sku(product.identity.sku)
        spree_variant=Spree::Variant.find_by_brightpearl_product_id(product.id)
        if spree_variant
          if spree_variant.total_on_hand!=product.on_hand
            wrong_stock << "#{spree_variant.name} #{spree_variant.options_text}: spree=#{spree_variant.total_on_hand}, bp=#{product.on_hand} (ID: #{spree_variant.brightpearl_product_id})"
          end
         else
          log "Couldn't find spree variant for #{product.identity.sku}", :product=>product
        end
      end
      wrong_stock
    end


    def self.reset_prices
      master_price_list={}
      brightpearl_products.each do |product|
        #spree_variant=Spree::Variant.find_by_sku(product.identity.sku)
        spree_variant=Spree::Variant.find_by_brightpearl_product_id(product.id)
        if spree_variant
          price=product.price
          spree_variant.price=price
          spree_variant.save

          spree_product=spree_variant.product
          master_price_list[spree_product.id] ||= price
          #TODO: should raise exception if all variant prices don't match
          raise PriceMismatchError, "Price was #{price}, but already set to #{master_price_list[spree_product.id]} for #{spree_product.name}" if master_price_list[spree_product.id]!=price

          spree_product.price=price
          spree_product.save
        else
          log "Couldn't find spree variant for #{product.identity.sku}", :product=>product
        end
      end
    end

    def self.reset_shipping_categories
      brightpearl_products.each do |product|
        spree_variant=Spree::Variant.find_by_brightpearl_product_id(product.id)
        if spree_variant
          spree_variant.product.shipping_category_id=find_shipping_category_id(product)
          spree_variant.product.save
        end
      end
    end


    def self.find_shipping_category_id(bp_product)
       return 7 if bp_product.custom_field('PCF_SHIPPING').blank?

       case bp_product.custom_field('PCF_SHIPPING').id
         when 6
          return 7
         when 7
          return 10
         when 68
          return 8
         when 69
          return 9
         else
          raise RuntimeError, "No shipping category map exists for #{bp_product.inspect}"
        end



      # in spree
      # 7 - default
      # 8 - ground/usa only
      # 9 - usa only/no export
      # 10 - special delivery

      # in brightpearl
      # 69 -  cannot ship outside USA
      # 7 - special delivery
      # 6 - standard
      # 68 - Ground

    end


    def self.reorder_variants
      Spree::Variant.where(:is_master=>false).each do |variant|
        position=ORDERED_OPTIONS.index variant.option_values.first.presentation
        variant.update_attribute(:position, position)
      end
    end

    def self.reassociate_brightpearl_by_sku
      brightpearl_products.each do |p|
      	v=Spree::Variant.where(sku: p.identity.sku).first
      	begin
        	if v
        		product_group_id=p.productGroupId
        		verify_product(p,v)
        		v.brightpearl_product_id=p.id
        		v.brightpearl_brand_id=p.brandId
        		v.brightpearl_product_group_id=product_group_id
        		v.save
        	else
        		log "No sku in variants", :product=>p, :errors=>"No sku in variants"
        	end
        rescue ProductMismatchError => e
          log "Product mismatch #{e}", :product=>p, :variant=>v
        end
      end
    end



    def self.reassociate_product_group_ids
      brightpearl_products.each do |product|
        product_group_id=product.productGroupId
        variant=Spree::Variant.find_by_brightpearl_product_id(product.id)
        variant.brightpearl_product_group_id=product_group_id
        variant.save
      end
    end

    def self.reload_webhooks
      webhooks=::Brightpearl::IntegrationService::Webhook.all
      webhooks && webhooks.each do |webhook|
        if webhook.uriTemplate =~ /www.elanstudio.com/
          webhook.destroy
        end
      end

      new_webhooks=YAML.load_file 'config/brightpearl_webhooks.yml'
      new_webhooks.delete('common')

      new_webhooks.each do |k,new_webhook|
        ::Brightpearl::IntegrationService::Webhook.new(new_webhook).save
      end

    end

#     def self.recreate_variants_by_product_name
#       brightpearl_products_by_name.each do |product_group_name, product_group_products|
#         spree_product=Spree::Product.find_by_name(product_group_name)
#         spree_product.variants.destroy_all
#         spree_product.master.option_values.destroy_all
#         spree_product.master.sku=''
#         spree_product.master.brightpearl_product_id=nil
#         spree_product.master.brightpearl_product_group_id=nil
#         spree_product.master.brightpearl_brand_id=nil
#
#         if product_group_products.count > 1
#           product_group_products.each do |id,brightpearl_product|
#             brightpearl_product.variations.each do |variant|
#               set_variant_fields(spree_product.variants.build,variant,brightpearl_product)
#             end
#           end
#         else
#           product_group_products.each do |id,brightpearl_product|
#             #set brightpearl variant to nil because this is a master product
#             set_variant_fields(spree_product.master,nil,brightpearl_product)
#           end
#         end
#
#         spree_product.save
#       end
#     end

  end
end
