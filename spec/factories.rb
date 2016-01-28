require 'snippet'

FactoryGirl.define do
  sequence(:random_string) {|n| Faker::Lorem.sentence }
  sequence(:unique_product_name) {|n| "Product-Name##{n}"}
  sequence(:brightpearl_product_id) { |n| n.to_i }
  sequence(:brightpearl_product_group_id) { |n| n.to_i }
  sequence(:brightpearl_brand_id) { |n| n.to_i }
  sequence(:unique_sku) {|n| "Sku+#{n}"}
  sequence(:random_description) { Faker::Lorem.paragraphs(1 + Kernel.rand(5)).join("\n") }
  sequence(:random_email)       { |n| "#{n}-#{Faker::Internet.email}" }
  sequence(:base_name) { |n| "#{Faker::Name.last_name}-#{n}-#{Time.now}"}
  sequence(:full_name) { |n| "#{Faker::Name.name}-#{n}"}
  sequence(:short_name) { |n| "#{Faker::Name.first_name}-#{n}"}
  sequence(:random_float) { BigDecimal.new("#{rand(200)}.#{rand(99)}") }


####### Custom Store #######

  factory :wishlist_item do

  end

  factory :product_notification do

  end

####### Spree Factories ########

  factory :spree_user, class: Spree::User do
    firstname "Frank"
    lastname "Jones"
    sequence(:email) {|n| "test_#{n}@test.com" }
    password "qwerty1234"
    spree_roles {[Spree::Role.find_or_create_by(name: 'user')]}

    factory :spree_admin_user do
      spree_roles {[Spree::Role.find_or_create_by(name: 'admin')]}
    end

    factory :spree_retail_user do
      spree_roles {[Spree::Role.find_or_create_by(name: 'retail')]}
    end

    factory :spree_staff_user do
      spree_roles {[Spree::Role.find_or_create_by(name: 'staff')]}
    end


    factory :spree_user_with_address do
      ship_address
      bill_address
    end

    trait :with_stored_card do
      credit_cards {[FactoryGirl.create(:credit_card)]}
    end

  end


  factory :address, aliases: [:bill_address, :ship_address], class: Spree::Address do
    firstname 'John'
    lastname 'Doe'
    company 'Company'
    address1 '10 Lovely Street'
    address2 'Northwest'
    city 'Herndon'
    zipcode '35005'
    phone '123-456-7890'
    alternative_phone '123-456-7899'

    state { |address| address.association(:state) }
    country do |address|
      if address.state
        address.state.country
      else
        address.association(:country)
      end
    end
  end

  factory :braintree_sandbox_payment_method, class: Spree::Gateway::BraintreeGateway do
    type "Spree::Gateway::BraintreeGateway"
    name Settings.braintree.name
    active true
    display_on ''
    deleted_at nil
    after(:create) do |payment_method|
      payment_method.set_preference :merchant_id, Settings.braintree.merchant_id
      payment_method.set_preference :public_key, Settings.braintree.public_key
      payment_method.set_preference :private_key, Settings.braintree.private_key
      payment_method.set_preference :client_side_encryption_key, Settings.braintree.client_side_encryption_key
      payment_method.set_preference :environment, Settings.braintree.environment
    end
  end

  factory :calculator, class: Spree::Calculator::FlatRate do
    after(:create) { |c| c.set_preference(:amount, 10.0) }
  end

  factory :check_payment_method, class: Spree::PaymentMethod::Check do
    name 'Check'
    environment 'test'
  end

  factory :country, class: Spree::Country do
    iso_name 'UNITED STATES'
    name 'United States of America'
    iso 'US'
    iso3 'USA'
    numcode 840

    after(:create) do |country|
        FactoryGirl.create(:zone_member, zoneable_id: country.id, zoneable_type: country.class.name, zone: ( Spree::Zone.first || FactoryGirl.create(:zone)))
    end
  end

  factory :credit_card_payment_method, class: Spree::Gateway::Bogus do
    name 'Credit Card'
  end

  factory :credit_card, class: Spree::CreditCard do
    verification_value 123
    month 12
    year { 1.year.from_now.year }
    number '4111111111111111'
    name 'Spree Commerce'
    association(:payment_method, factory: :credit_card_payment_method)
    gateway_customer_profile_id 123 # ugh, spree devs, COME ON.
  end

  factory :default_tax_calculator, class: Spree::Calculator::DefaultTax do
  end

  factory :no_amount_calculator, class: Spree::Calculator::FlatRate do
    after(:create) { |c| c.set_preference(:amount, 0) }
  end

  factory :option_type, class: Spree::OptionType do
    sequence(:name) { |n| "OptionType ##{n} - #{Kernel.rand(9999)}" }
    presentation 'Size'
  end

  factory :option_value, class: Spree::OptionValue do
    name 'Size'
    presentation 'S'
    option_type

    factory :option_value_out_of_stock do
      presentation 'M'
    end
  end

  factory :preexisting_user, class: Spree::User do
    email { Faker::Internet.email }
    firstname Faker::Name.first_name
    lastname Faker::Name.last_name
    password "qwerty1234"
    password_confirmation "qwerty1234"

    bill_address
    ship_address
  end

  # Products
  factory :base_product, class: Spree::Product do
    sequence(:name) { |n| "Product ##{n} - #{Kernel.rand(9999)}" }
    description { generate(:random_description) }
    price 19.99
    cost_price 17.00
    sku { "ABC-#{Kernel.rand(9999)}" }
    available_on { 1.year.ago }
    deleted_at nil
    shipping_category { |r| Spree::ShippingCategory.first || r.association(:shipping_category) }

    brightpearl_product_id { generate(:brightpearl_product_id)}
    brightpearl_brand_id { FactoryGirl.create(:brand).brightpearl_brand_id }
    brightpearl_product_group_id { generate(:brightpearl_product_group_id) }

     # Make sure there will be an Author for CMS linking callback
    cms_product_attributes {{
        tags: 'test',
        categories: 'test',
        author_id: FactoryGirl.create(:author).id,
        site_id: ClearCMS::Site.first.id,
        product_state: 'Current'
        # special_delivery: special_delivery
    }}

    # ensure stock item will be created for this products master
    before(:create) { create(:stock_location, :default) if Spree::StockLocation.count == 0 }

    # Give the product one item in stock.
    after(:create) { |product| product.stock_items.last.set_count_on_hand(1) }

    # Reload the master variant into the cache
    after(:create) do |product|
      product.master.touch
      product.master.reload
      # TODO: why do i have to do this?
     end


    factory :custom_product do
      name 'Custom Product'
      price 17.99

      tax_category { |r| Spree::TaxCategory.first || r.association(:tax_category) }
    end

    factory :product do
      tax_category { |r| Spree::TaxCategory.first || r.association(:tax_category) }

      factory :product_with_option_types do
        after(:create) { |product| create(:product_option_type, product: product) }
        after(:create) { |product| create(:option_value, option_type: product.option_types.first)}
        after(:create) { |product| create(:variant, product: product)}
        after(:create) { |product| create(:variant_out_of_stock, product: product)}
      end
    end
  end # End products

  factory :product_option_type, class: Spree::ProductOptionType do
    product
    option_type
  end

  factory :shipping_category, class: Spree::ShippingCategory do
    sequence(:name) { |n| "ShippingCategory ##{n}" }
  end

  factory :base_shipping_method, class: Spree::ShippingMethod do
    # zones { |a| [Spree::Zone.global] }
    name 'UPS Ground'

    before(:create) do |shipping_method, evaluator|
      if shipping_method.shipping_categories.empty?
        shipping_method.shipping_categories << (Spree::ShippingCategory.first || create(:shipping_category))
      end
    end

    factory :shipping_method, class: Spree::ShippingMethod do
      association(:calculator, factory: :calculator, strategy: :build)
      after(:create) { }
    end

    factory :free_shipping_method, class: Spree::ShippingMethod do
      association(:calculator, factory: :no_amount_calculator, strategy: :build)
    end
  end

  factory :simple_credit_card_payment_method, class: Spree::Gateway::BogusSimple do
    name 'Credit Card'
    environment 'test'
  end

  factory :state, class: Spree::State do
    name 'Alabama'
    abbr 'AL'
    country do |country|
      if usa = Spree::Country.find_by_numcode(840)
        country = usa
      else
        country.association(:country)
      end
    end
    after(:create) do |state|
        FactoryGirl.create(:zone_member, zoneable_id: state.id, zoneable_type: state.class.name, zone: ( Spree::Zone.first || FactoryGirl.create(:zone)))
    end
  end

  factory :stock_item, class: Spree::StockItem do
    backorderable false
    stock_location
    variant

      factory :stock_item_at_non_default_warehouse do
        stock_location { |stock_location| stock_location.association(:stock_location, :not_default) }
      end

    after(:create) { |object| object.adjust_count_on_hand(1) }
  end

  factory :stock_location, class: Spree::StockLocation do
    name 'Greene Street'
    address1 '1600 Pennsylvania Ave NW'
    city 'Washington'
    zipcode '20500'
    phone '(202) 456-1111'
    active true
    backorderable_default true

    country  { |stock_location| Spree::Country.first || stock_location.association(:country) }
    state do |stock_location|
      stock_location.country.states.first || stock_location.association(:state, :country => stock_location.country)
    end

    factory :stock_location_with_items do
      after(:create) do |stock_location, evaluator|
        # variant will add itself to all stock_locations in an after_create
        # creating a product will automatically create a master variant
        product_1 = create(:product)
        product_2 = create(:product)

        stock_location.stock_items.where(:variant_id => product_1.master.id).first.adjust_count_on_hand(10)
        stock_location.stock_items.where(:variant_id => product_2.master.id).first.adjust_count_on_hand(20)
      end
    end

    trait :default do
      name 'Ecommerce Default'
      default true
    end

    trait :not_default do
      default false
      propagate_all_variants false
    end

  end

  factory :tax_category, class: Spree::TaxCategory do
    name { "TaxCategory - #{rand(999999)}" }
    description { generate(:random_string) }
  end

  # Variants
  factory :base_variant, class: Spree::Variant do

    # These brightpearl IDs just help validations pass
    brightpearl_product_id { generate(:brightpearl_product_id)}
    brightpearl_brand_id { FactoryGirl.create(:brand).brightpearl_brand_id }
    brightpearl_product_group_id { generate(:brightpearl_product_group_id)}

    price 19.99
    cost_price 17.00
    sku    { SecureRandom.hex }
    weight { generate(:random_float) }
    height { generate(:random_float) }
    width  { generate(:random_float) }
    depth  { generate(:random_float) }
    is_master 0
    track_inventory true

    product { |p| p.association(:base_product) }
    option_values { [create(:option_value)] }

    # ensure stock item will be created for this variant
    before(:create) { create(:stock_location) if Spree::StockLocation.count == 0 }


    factory :variant do
      # on_hand 5
      product { |p| p.association(:product) }
      after(:create) do |variant|
        variant.stock_items.each do |stock_item|
        stock_item.set_count_on_hand(1)
        end
      end
    end

    factory :master_variant do
      is_master 1
    end

    factory :variant_out_of_stock do
      # has_and_belongs_to_many :option_values, join_table: :spree_option_values_variants
      option_values { [create(:option_value_out_of_stock)] }
      after(:create) do |variant|
        variant.stock_items.each do |stock_item|
        stock_item.set_count_on_hand(0)
        end
      end
    end

    factory :on_demand_variant do
      track_inventory false

      factory :on_demand_master_variant do
        is_master 1
      end
    end

  end # End Variants

  # Zones

  factory :global_zone, class: Spree::Zone do
    name 'GlobalZone'
    description { generate(:random_string) }
    zone_members do |proxy|
      zone = proxy.instance_eval { @instance }
      Spree::Country.all.map do |c|
        zone_member = Spree::ZoneMember.create(zoneable: c, zone: zone)
      end
    end
    shipping_methods { [FactoryGirl.create(:shipping_method)]}
  end

  factory :zone, class: Spree::Zone do
    name { generate(:random_string) }
    description { generate(:random_string) }
    shipping_methods { [FactoryGirl.create(:shipping_method)]}
    # after(:create) { |zone| FactoryGirl.create(:zone_member, zoneable_id: zone.id, zoneable_type: zone.class.to_s, zone_id: zone)}
  end

  factory :zone_member, class: Spree::ZoneMember do
  end

####### End Spree Factories #######


####### ClearCMS Factories #######
  factory :author, class: ClearCMS::User do
    full_name { generate(:full_name) }
    base_name { generate(:base_name) }
    short_name { generate(:short_name) }
    email { generate(:random_email) }
    password "qwerty1234"
    password_confirmation "qwerty1234"
    system_permission "administrator"
    active true
  end

  factory :content, class: ClearCMS::Content do
    title { generate(:random_string)}
    subtitle { generate(:random_string)}
    sequence(:basename) {|n| "#{Faker::Lorem.words(3).join('_')}_#{n}"}
    site  { |r| ClearCMS::Site.first || r.association(:site) }

    author
    tags { Faker::Lorem.words(5) }
    categories { Faker::Lorem.words(3) }

    # after(:build) do |cms_product|
      # cms_product.spree_product_id=FactoryGirl.create(:product).id
      # cms_product.spree_product_id=FactoryGirl.create(:stock_item).product.id
      # cms_product.spree_product_id=FactoryGirl.create(:master_variant_with_product).product.id
    # end

    trait :published do
      state 'Finished'
      publish_at {Time.now}
    end

    trait :product do
      author
      _type 'Product'
      categories { %w(fashion home beauty)[Random.rand(3)]}
      # content_blocks {[FactoryGirl.build(:content_block, :content=>self, :body=>Faker::Lorem.paragraph(10))]}
      content_blocks {[FactoryGirl.build(:content_block, :content=>self), FactoryGirl.build(:content_block, :content=>self, :type=>'description'),FactoryGirl.build(:content_block, :content=>self, :type=>'details'),FactoryGirl.build(:content_block, :content=>self, :type=>'sizing')]}
      brand { |r| Brand.first || r.association(:published_brand_content) }
      #price { (rand*rand(50000)).round(2) }
      #sequence(:product_variant_id)
    end


    trait :editorial do
      _type 'Editorial'
      categories { %w(ultimate_closet 1_item_5_ways profile_piece)[Random.rand(3)]}
    end


    trait :volume do
      _type 'Volume'
      sequence(:volume_number) {|n| n }
    end

    trait :chapter do
      _type 'Chapter'
      sequence(:chapter_number) {|n| n }
      #volume { FactoryGirl.build(:published_volume_content) }
      #byline { "#{Faker::Name.first_name} #{Faker::Name.last_name}"}
      content_blocks {[FactoryGirl.build(:content_block, :content=>self), FactoryGirl.build(:content_block, :content=>self, :type=>'description')]}
    end

    trait :apartment do
      _type 'Apartment'
      sequence(:apartment_number) {|n| n}
      #volume { FactoryGirl.build(:published_volume_content) }
    end

    trait :event do
      _type 'Event'
      start_time {Faker::Time.date}
      end_time { Time.parse(start_time) + Random.rand(100000).minutes }
      #apartment { FactoryGirl.build(:published_apartment_content) }
    end

    trait :page do
      _type 'Page'
    end

    trait :selection do
      _type 'Selection'
      state 'Finished'
      publish_at { 2.years.ago }
    end

    trait :archived_selection do
      _type 'Selection'
      state 'Finished'
      end_time { 1.year.ago }
      publish_at { 2.years.ago }
    end

    trait :featured do
      is_featured true
    end

    content_blocks {[FactoryGirl.build(:content_block, :content=>self)]}

    factory :product_content, traits: [:product]
    factory :published_product_content, traits: [:published, :product], class: Product do
      author
    end

    factory :editorial_content, traits: [:editorial]
    factory :published_editorial_content, traits: [:published, :editorial]

    factory :brand_content, traits: [:brand]
    factory :published_brand_content, traits: [:published, :brand, :content_basics]

    factory :volume_content, traits: [:volume]
    factory :published_volume_content, traits: [:published, :volume]

    factory :chapter_content, traits: [:chapter]
    factory :published_chapter_content, traits: [:published, :chapter]

    factory :apartment_content, traits: [:apartment]
    factory :published_apartment_content, traits: [:published, :apartment]

    factory :event_content, traits: [:event]
    factory :published_event_content, traits: [:published,:event]

    factory :page_content, traits: [:page]
    factory :published_page_content, traits: [:published,:page]
  end  # End Content Factory

  factory :brand, class: Brand do
    _type 'Brand'
    designer { Faker::Name.name }
    location { "#{Faker::Address.city}, #{Faker::AddressUS.state}" }
    established { 1900+Random.rand(100)}
    sequence(:brightpearl_brand_id)
    # brightpearl_brand_id { Brand.first.id || sequence(:brightpearl_brand_id) }

    title { generate(:random_string) }
    subtitle { generate(:random_string) }
    author
    basename { generate(:random_string) }
    tags 'test'
    categories 'test'
    site { ClearCMS::Site.find_or_create_by(:name=>'The Line', :slug=>'theline', :domain=>'theline.com') }
  end

  trait :content_basics do
    title { generate(:random_string)}
    subtitle { generate(:random_string)}
    sequence(:basename) {|n| "#{Faker::Lorem.words(3).join('_')}_#{n}"}
    site  { |r| ClearCMS::Site.first || r.association(:site) }
    author { FactoryGirl.build(:user)}
    tags { Faker::Lorem.words(5) }
    categories { Faker::Lorem.words(3) }
  end

    trait :brand do
      _type 'Brand'
      designer { Faker::Name.name }
      location { "#{Faker::Address.city}, #{Faker::AddressUS.state}" }
      established { 1900+Random.rand(100)}
    end

  factory :content_block, class: ClearCMS::ContentBlock do
    type 'raw'
    body {
      case content._type
      when 'Chapter'
        Snippet.random_html("chapter/#{type}")
      when 'Product'
        Snippet.random_html("product/#{type}")
      else
        Faker::Lorem.paragraph(20)
      end
    }

    transient do
      content_asset_count 5
    end

    content_assets {content_asset_count.times.collect {FactoryGirl.build(:content_asset, :content_block=>self)}}
  end

  factory :content_asset, class: ClearCMS::ContentAsset do
    path {
      case content_block.content._type
      when 'Product'
        #"theline/placeholders/#{content_block.content._type.downcase}"
        "theline/placeholders/product"
      else
        "theline/placeholders/editorial"
      end
    }

    transient do
      available_image_count 83
    end

    #path 'theline/2013/07/29' 1-124 images
    file {
      case content_block.content._type
      when 'Product'
        available_image_count=83
      else
        available_image_count=123
      end

      "image_#{Random.rand(available_image_count||10)+1}.jpg"
    }
  end

  factory :site, class: ClearCMS::Site do
    name { "Site #{Faker::Lorem.word}" }
    sequence(:domain) {|n| "#{Faker::Lorem.words(2).join('')}#{n}.com" }
    sequence(:slug) {|n| "#{Faker::Lorem.words(2).join''}#{n}"}
  end

  factory :user, class: ClearCMS::User do
    email { generate(:random_email) }
  end

end
