class AddBrightpearlToSpreeVariant < ActiveRecord::Migration
  def change
    add_column :spree_variants, :brightpearl_product_id, :integer
    add_column :spree_variants, :brightpearl_brand_id, :integer
    add_column :spree_variants, :brightpearl_product_group_id, :integer
  end
end
