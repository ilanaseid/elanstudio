class AddTypeAndEnvToSupportRequest < ActiveRecord::Migration
  def change
    add_column :support_requests, :request_type, :string
    add_column :support_requests, :user_environment, :text
  end
end
