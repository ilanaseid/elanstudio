class IndexVariantIdOnStockItems < ActiveRecord::Migration
  def up
  	add_index :spree_stock_items, :variant_id
  end

  def down
  	remove_index :spree_stock_items, :variant_id
  end
end
