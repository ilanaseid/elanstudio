class CreateEmailInterestGroups < ActiveRecord::Migration
  def change
    create_table :email_interest_groups do |t|
      t.belongs_to :email_list, index: true
      t.integer :mailchimp_grouping_id
      t.integer :mailchimp_id
      t.string :display_name
      t.string :short_description
      t.string :mailchimp_name
    end
  end
end
