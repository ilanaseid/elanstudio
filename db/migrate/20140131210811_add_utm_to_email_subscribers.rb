class AddUtmToEmailSubscribers < ActiveRecord::Migration
  def change
    add_column :email_subscribers, :utm_source, :string
    add_column :email_subscribers, :utm_medium, :string
  end
end
