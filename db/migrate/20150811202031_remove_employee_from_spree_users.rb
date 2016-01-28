class RemoveEmployeeFromSpreeUsers < ActiveRecord::Migration
  def change
    remove_column :spree_users, :employee, :boolean
  end
end
