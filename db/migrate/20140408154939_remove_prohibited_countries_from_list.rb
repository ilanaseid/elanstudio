class RemoveProhibitedCountriesFromList < ActiveRecord::Migration
  def up
  	Spree::Country.where("name like 'x%'").destroy_all
  end

  def down
  end
end
