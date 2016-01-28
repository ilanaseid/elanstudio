collection @products
node(:id) {|p| p.id.to_s }
attributes :title

child :spree_product => :spree_product do |spree_product|
  attributes :id
  node :locations do
    child Spree::StockLocation.active.all.to_a => :locations do
      attributes :id, :name
      node(:variants) do |location|
        if spree_product.has_variants?
          spree_product.variants.collect do |variant|
            {
              id: variant.id,
              option_values: variant.option_values.collect {|o| o.presentation }.join(' - '),
              count_on_hand: variant.location_count_on_hand(location)
            }
          end
        else
        spree_product.variants_including_master.collect do |variant|
            {
              id: variant.id,
              option_values: variant.option_values.collect {|o| o.presentation }.join(' - '),
              count_on_hand: variant.location_count_on_hand(location)
            }
          end
        end
      end
    end
  end
end
