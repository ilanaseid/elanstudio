class SetAdminStaffUsers < ActiveRecord::Migration
  def up
    #Create admin role
    admin_role=Spree::Role.create(:name => 'admin')
    staff_role=Spree::Role.create(:name => 'staff')
    
    #Set admin employees
    %w(ilana@elanstudio.com).each do |email|
      Spree::User.find_by_email(email).spree_roles << admin_role
      Spree::User.find_by_email(email).spree_roles << staff_role
    end
     
  end

  def down
  end

end
