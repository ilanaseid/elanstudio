class ChangeColumnOnApartmentVisits < ActiveRecord::Migration
  def up
    remove_column :apartment_visits, :what_time
    add_column :apartment_visits, :what_time, :string
  end

  def down
  end
end
