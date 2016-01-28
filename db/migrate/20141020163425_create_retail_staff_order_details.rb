class CreateRetailStaffOrderDetails < ActiveRecord::Migration
  def change
    create_table :retail_staff_order_details do |t|
      t.integer :spree_order_id
      t.string :customer_id
      t.string :trade_discount
      t.string :shipping_method
      t.string :internal_comments
      t.timestamps
    end
  end
end
