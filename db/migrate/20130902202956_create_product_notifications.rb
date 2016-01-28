class CreateProductNotifications < ActiveRecord::Migration
  def change
    create_table :product_notifications do |t|
      t.string :name
      t.string :email
      t.integer :spree_variant_id
      t.datetime :sent_at

      t.timestamps
    end
  end
end
