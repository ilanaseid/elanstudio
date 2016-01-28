class CreateEmailList < ActiveRecord::Migration
  def change
    create_table :email_lists do |t|
      t.string :name
      t.string :mailchimp_list_id
      t.string :short_description
    end
  end
end
