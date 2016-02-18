class AddNamesToSpreeUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :firstname, :string
    add_column :spree_users, :lastname, :string
    add_column :spree_users, :newsletter, :boolean
  end
end
