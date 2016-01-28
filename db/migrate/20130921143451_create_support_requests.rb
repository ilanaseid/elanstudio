class CreateSupportRequests < ActiveRecord::Migration
  def change
    create_table :support_requests do |t|
      t.string :email
      t.text :comment

      t.timestamps
    end
  end
end
