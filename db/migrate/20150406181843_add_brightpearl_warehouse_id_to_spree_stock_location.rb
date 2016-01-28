class AddBrightpearlWarehouseIdToSpreeStockLocation < ActiveRecord::Migration
  def up
    add_column :spree_stock_locations, :brightpearl_warehouse_id, :integer
  
    # Set the existing stock location to the default brightpearl warehouse of 2 (ecommerce)
    Spree::StockLocation.find(1).update_attribute(:brightpearl_warehouse_id, 2)
  end
  
  def down 
    remove_column :spree_stock_locations, :brightpearl_warehouse_id
  end 
end
