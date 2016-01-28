module Reporting

  class ShareASaleProductFeed
    include Sidekiq::Worker
    include ActionView::Helpers::SanitizeHelper

    SHARE_A_SALE_CATEGORY_TAXONOMY={
      fashion: 8,
      home: 11,
      beauty: 12,
      art: 1
    }

    SHARE_A_SALE_SUBCATEGORY_TAXONOMY={
      fashion: {
        tops: 59,
        bottoms: 59,
        dresses: 59,
        jackets: 59,
        outerwear: 59,
        shoes: 61,
        accessories: 62,
        bags: 62,
        swim: 59,
        jewelry: 64,
        lingerie: 65
      },
      home: {
        furniture: 97,
        tableware: 98,
        lighting: 98,
        textiles: 98,
        rugs: 98,
        accessories: 98,
        books: 98,
        cleaning: 96
      },
      beauty: {
        face: 102,
        bath_body: 102,
        hair: 102,
        fragrance: 102
      },
      art: {
        art: 1
      }
    }

    def perform(email='bailey@theline.com')
      CSV.open("share_a_sale_product_feed.csv","wb") do |csv|
        Product.published.each do |p|
          next if p.external?
          if p.spree_product.variants.any?
            p.spree_product.variants.each do |variant|
              csv << csv_fields(p, sku: variant.sku, size: variant.options_label) if variant.default_location_count_on_hand > 2
            end
          else
            csv << csv_fields(p, sku: p.spree_product.sku) if p.spree_product.default_location_total_on_hand > 2
          end
        end
      end
      attachments=[{:name=>'share_a_sale_product_feed.csv', :content=>File.read('share_a_sale_product_feed.csv')}]
      SystemMailer.general("#{email}",'ShareASale Product Feed', 'Please find attached the CSV of products for ShareASale Product Feed', attachments).deliver
    end


    def csv_fields(p, sku: 'SKU', size: '')
      [ sku, # SKU
        p.spree_product.name.gsub('|', '-'), # Name
        "https://www.theline.com#{p.friendly_path}", # Direct URL to product
        sprintf('%.2f',p.spree_product.price.to_i), # Price
        '', # Original price
        p.default_image.mounted_file.medium.url, # URL to product image
        '', # URL to thumbnail image
        sprintf('%.2f',p.spree_product.price.to_i * 0.07), # Dollar amount of commission - for reference only
        share_a_sale_category_lookup(p), # Integer for shareasale category
        share_a_sale_subcategory_lookup(p), # Integer for shareasale subcategory
        strip_tags(p.content_block('description').body).gsub('|', '-').to_s,
        p.categories.join(", ").gsub('|', '-'), # Search terms
        'instock', # Status
        '55717', # Merchant ID
        'Custom 1',
        'Custom 2',
        'Custom 3',
        'Custom 4',
        'Custom 5',
        p.brand.title.gsub('|', '-'), # Manufacturer
        '', # PartNumber
        SHARE_A_SALE_CATEGORY_TAXONOMY.key(share_a_sale_category_lookup(p)), # Merchant Category
        p.categories.join(", ").gsub('|', '-'), # Merchant Subcategory
        p.title.gsub('|', '-'), # Short Description
        '', # ISBN
        '', # UPC
        '', # CrossSell
        '', # MerchantGroup
        '', # MerchantSubgroup
        '', # CompatibleWith
        '', # CompareTo
        '', # QuantityDiscount
        '', # Bestseller
        '', # AddToCartURL
        '', # ReviewsRSSURL
        'Option1',
        'Option2',
        'Option3',
        'Option4',
        'Option5',
        sprintf('%.2f', 7.00),
        '', #ReservedForFutureUse
        '', #ReservedForFutureUse
        '', #ReservedForFutureUse
        '', #ReservedForFutureUse
        '', #ReservedForFutureUse
        '', #ReservedForFutureUse
        '', #ReservedForFutureUse
        '', #ReservedForFutureUse
        ''  #ReservedForFutureUse
      ]
    end

    def share_a_sale_category_lookup(p)
      category=nil
      p.categories.each do |cat|
        category=SHARE_A_SALE_CATEGORY_TAXONOMY[cat.downcase.to_sym]
        break if category
      end
      return category
    end

    def share_a_sale_subcategory_lookup(p)
      category = SHARE_A_SALE_CATEGORY_TAXONOMY.key(share_a_sale_category_lookup(p))

      subcategory=nil
      p.categories.each do |cat|
        subcategory=SHARE_A_SALE_SUBCATEGORY_TAXONOMY[category.downcase.to_sym][cat.downcase.to_sym] if category
        break if subcategory
      end
      return subcategory
    end

  end
end
