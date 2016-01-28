class AddFieldsToEmailSubscriber < ActiveRecord::Migration
  def change
    add_column :email_subscribers, :zipcode, :string
    add_column :email_subscribers, :interests, :string
  end
end
