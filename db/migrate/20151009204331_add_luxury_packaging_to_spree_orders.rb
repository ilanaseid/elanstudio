class AddLuxuryPackagingToSpreeOrders < ActiveRecord::Migration
  def change
  	add_column :spree_orders, :luxury_packaging, :boolean, :default => true
  end
end
