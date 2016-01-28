class CreateApartmentVisits < ActiveRecord::Migration
  def change
    create_table :apartment_visits do |t|
      t.string :name
      t.string :email
      t.datetime :what_time
      t.text :note

      t.timestamps
    end
  end
end
