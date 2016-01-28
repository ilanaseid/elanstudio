class AddBrightpearlToSpreeOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :brightpearl_order_id, :integer
  end
end
