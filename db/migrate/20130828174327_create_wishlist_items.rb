class CreateWishlistItems < ActiveRecord::Migration
  def change
    create_table :wishlist_items do |t|
      t.integer :user_id
      t.integer :variant_id

      t.timestamps
    end
  end
end
