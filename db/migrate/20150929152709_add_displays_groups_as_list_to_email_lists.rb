class AddDisplaysGroupsAsListToEmailLists < ActiveRecord::Migration
  def change
    add_column :email_lists, :displays_groups_as_lists, :boolean, default: false
  end
end
