class SetStaffUsers < ActiveRecord::Migration
  def up
    #Create retail role
    role=Spree::Role.find_or_create_by_name('retail')
    
    #Set retail employees
    %w(allee@theline.com kyra@theline.com sarahb@theline.com).each do |email|
      Spree::User.find_by_email(email).spree_roles << role
    end
    
    #Set all theline.com users as employees
    Spree::User.where("email like ?",'%@theline.com').update_all(employee: true)
    
    #Set based on response for user accounts email
    additional_emails=%w(mechung@gmail.com footebailey@gmail.com joel@niedfeldt.com msprout@me.com chris@placenamehere.com stephanie.murg@gmail.com room1015@me.com)
    Spree::User.where(email: additional_emails).update_all(employee: true)
    
  end

  def down
  end
end
