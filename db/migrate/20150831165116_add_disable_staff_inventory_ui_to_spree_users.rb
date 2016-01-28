class AddDisableStaffInventoryUiToSpreeUsers < ActiveRecord::Migration
  def change
    add_column :spree_users, :disable_staff_inventory_ui, :boolean
  end
end
