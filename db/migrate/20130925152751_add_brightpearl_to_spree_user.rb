class AddBrightpearlToSpreeUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :brightpearl_contact_id, :integer
  end
end
