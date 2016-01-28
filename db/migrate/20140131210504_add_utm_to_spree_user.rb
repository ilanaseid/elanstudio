class AddUtmToSpreeUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :utm_source, :string
    add_column :spree_users, :utm_medium, :string
  end
end
