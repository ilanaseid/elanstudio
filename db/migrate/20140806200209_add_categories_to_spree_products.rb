class AddCategoriesToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :categories, :text
  end
end
