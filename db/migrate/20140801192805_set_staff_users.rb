class SetStaffUsers < ActiveRecord::Migration
  def up
    #Create retail role
    role=Spree::Role.find_or_create_by_name('retail')
    
    #Set retail employees
    %w(loft@elanstudio.com).each do |email|
      Spree::User.find_by_email(email).spree_roles << role
    end
    
    #Set all theline.com users as employees
    Spree::User.where("email like ?",'%@elanstudio.com').update_all(employee: true)
    
    #Set based on response for user accounts email
    additional_emails=%w()
    Spree::User.where(email: additional_emails).update_all(employee: true)
    
  end

  def down
  end
end
