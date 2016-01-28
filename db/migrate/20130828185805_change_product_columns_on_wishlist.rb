class ChangeProductColumnsOnWishlist < ActiveRecord::Migration
  def change
    remove_column :wishlist_items, :spree_product_id
    add_column :wishlist_items, :spree_variant_id, :integer
  end
end
