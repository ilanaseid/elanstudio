class AddSpreeProductIdToWishlistItem < ActiveRecord::Migration
  def change
    remove_column :wishlist_items, :variant_id
    add_column :wishlist_items, :spree_product_id, :integer
  end
end
