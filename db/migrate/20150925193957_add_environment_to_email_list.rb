class AddEnvironmentToEmailList < ActiveRecord::Migration
  def change
    add_column :email_lists, :environment, :string
  end
end
