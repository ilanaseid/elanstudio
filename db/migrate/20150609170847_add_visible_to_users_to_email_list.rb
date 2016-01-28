class AddVisibleToUsersToEmailList < ActiveRecord::Migration
  def change
    add_column :email_lists, :visible_to_users, :boolean
  end
end
