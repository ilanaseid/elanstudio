# This migration comes from spree (originally 20150409190700)
class AddStockLocationIdToOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :stock_location_id, :integer
  end
end
