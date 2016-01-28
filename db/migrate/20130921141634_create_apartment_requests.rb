class CreateApartmentRequests < ActiveRecord::Migration
  def change
    create_table :apartment_requests do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.boolean :newsletter

      t.timestamps
    end
  end
end
