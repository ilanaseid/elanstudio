class RemoveBrightpearlFromSpreeVariant < ActiveRecord::Migration
  def change
    remove_column :spree_variants, :brightpearl_product_id, :integer
    remove_column :spree_variants, :brightpearl_brand_id, :integer
    remove_column :spree_variants, :brightpearl_product_group_id, :integer
  end
end
