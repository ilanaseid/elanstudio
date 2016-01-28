class AddFinalSaleToSpreeProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :final_sale, :boolean
  end
end
