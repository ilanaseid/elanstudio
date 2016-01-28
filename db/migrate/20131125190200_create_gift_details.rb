class CreateGiftDetails < ActiveRecord::Migration
  def change
    create_table :gift_details do |t|
      t.integer :spree_order_id
      t.string :to
      t.string :from
      t.text :message

      t.timestamps
    end
  end
end
