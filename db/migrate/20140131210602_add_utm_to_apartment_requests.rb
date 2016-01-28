class AddUtmToApartmentRequests < ActiveRecord::Migration
  def change
    add_column :apartment_requests, :utm_source, :string
    add_column :apartment_requests, :utm_medium, :string
  end
end
