class AddEmployeeToSpreeUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :employee, :boolean
  end
end
