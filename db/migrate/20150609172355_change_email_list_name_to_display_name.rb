class ChangeEmailListNameToDisplayName < ActiveRecord::Migration
  def change
    rename_column :email_lists, :name, :display_name
    add_column :email_lists, :mailchimp_name, :string
  end
end
